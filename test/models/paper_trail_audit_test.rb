# frozen_string_literal: true

require 'test_helper'

class PaperTrailAuditTest < ActiveSupport::TestCase
  test 'Product changes are tracked' do
    product = products(:product_one)
    assert_difference 'PaperTrail::Version.count' do
      product.update!(name: 'Updated Name')
    end

    version = product.versions.last
    assert_equal 'update', version.event
    assert_equal 'Product', version.item_type
    assert_equal product.id, version.item_id
  end

  test 'Product creates are tracked' do
    category = categories(:category_one)
    assert_difference 'PaperTrail::Version.count' do
      Product.create!(name: 'New Product', price: 1000, category: category)
    end

    version = PaperTrail::Version.last
    assert_equal 'create', version.event
    assert_equal 'Product', version.item_type
  end

  test 'Product destroys are tracked' do
    product = products(:product_three)
    product_id = product.id
    assert_difference 'PaperTrail::Version.count' do
      product.destroy!
    end

    version = PaperTrail::Version.last
    assert_equal 'destroy', version.event
    assert_equal product_id, version.item_id
  end

  test 'Category changes are tracked' do
    category = categories(:category_one)
    assert_difference 'PaperTrail::Version.count' do
      category.update!(name: 'Updated Category Name')
    end

    version = category.versions.last
    assert_equal 'update', version.event
    assert_equal 'Category', version.item_type
  end

  test 'Stock changes are tracked' do
    stock = stocks(:stock_one)
    assert_difference 'PaperTrail::Version.count' do
      stock.update!(stock_level: 50)
    end

    version = stock.versions.last
    assert_equal 'update', version.event
    assert_equal 'Stock', version.item_type
  end

  test 'Order changes are tracked' do
    order = orders(:order_one)
    assert_difference 'PaperTrail::Version.count' do
      order.update!(fulfilled: true)
    end

    version = order.versions.last
    assert_equal 'update', version.event
    assert_equal 'Order', version.item_type
  end

  test 'whodunnit is recorded' do
    PaperTrail.request.whodunnit = 'admin@example.com'
    product = products(:product_one)
    product.update!(name: 'Test')

    version = product.versions.last
    assert_equal 'admin@example.com', version.whodunnit
  ensure
    PaperTrail.request.whodunnit = nil
  end

  test 'object_changes records before and after values' do
    product = products(:product_one)
    old_name = product.name
    new_name = 'Changed Name'

    product.update!(name: new_name)
    version = product.versions.last

    assert version.object_changes.present?
    changes = YAML.safe_load(version.object_changes, permitted_classes: [Time, Date, BigDecimal])
    assert_equal old_name, changes['name'][0]
    assert_equal new_name, changes['name'][1]
  end
end
