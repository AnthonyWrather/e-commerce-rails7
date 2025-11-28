# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  def setup
    @category = categories(:category_one)
    @product = Product.new(
      name: 'Test Product',
      price: 1000,
      stock_level: 50,
      shipping_weight: 300,
      shipping_length: 100,
      shipping_width: 100,
      shipping_height: 5,
      category: @category,
      active: true
    )
  end

  # Name validations
  test 'should be valid with all required attributes' do
    assert @product.valid?
  end

  test 'should require name' do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test 'should require name to not be empty string' do
    @product.name = '   '
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test 'should allow valid name' do
    @product.name = 'Valid Product Name'
    assert @product.valid?
  end

  # Price validations
  test 'should require price' do
    @product.price = nil
    assert_not @product.valid?
    assert_includes @product.errors[:price], "can't be blank"
  end

  test 'should require price to be a number' do
    @product.price = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:price], 'is not a number'
  end

  test 'should require price to be greater than or equal to zero' do
    @product.price = -1
    assert_not @product.valid?
    assert_includes @product.errors[:price], 'must be greater than or equal to 0'
  end

  test 'should allow price of zero' do
    @product.price = 0
    assert @product.valid?
  end

  test 'should require price to be an integer' do
    @product.price = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:price], 'must be an integer'
  end

  test 'should allow valid price' do
    @product.price = 1500
    assert @product.valid?
  end

  # Stock level validations
  test 'should allow nil stock_level' do
    @product.stock_level = nil
    assert @product.valid?
  end

  test 'should require stock_level to be a number when present' do
    @product.stock_level = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:stock_level], 'is not a number'
  end

  test 'should require stock_level to be greater than or equal to zero' do
    @product.stock_level = -1
    assert_not @product.valid?
    assert_includes @product.errors[:stock_level], 'must be greater than or equal to 0'
  end

  test 'should allow stock_level of zero' do
    @product.stock_level = 0
    assert @product.valid?
  end

  test 'should require stock_level to be an integer' do
    @product.stock_level = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:stock_level], 'must be an integer'
  end

  test 'should allow valid stock_level' do
    @product.stock_level = 100
    assert @product.valid?
  end

  # Weight validations
  test 'should allow nil weight' do
    @product.shipping_weight = nil
    assert @product.valid?
  end

  test 'should require weight to be a number when present' do
    @product.shipping_weight = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_weight], 'is not a number'
  end

  test 'should require weight to be greater than zero when present' do
    @product.shipping_weight = 0
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_weight], 'must be greater than 0'
  end

  test 'should not allow negative weight' do
    @product.shipping_weight = -1
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_weight], 'must be greater than 0'
  end

  test 'should require weight to be an integer' do
    @product.shipping_weight = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_weight], 'must be an integer'
  end

  test 'should allow valid weight' do
    @product.shipping_weight = 300
    assert @product.valid?
  end

  # Length validations
  test 'should allow nil length' do
    @product.shipping_length = nil
    assert @product.valid?
  end

  test 'should require length to be a number when present' do
    @product.shipping_length = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_length], 'is not a number'
  end

  test 'should require length to be greater than zero when present' do
    @product.shipping_length = 0
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_length], 'must be greater than 0'
  end

  test 'should not allow negative length' do
    @product.shipping_length = -1
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_length], 'must be greater than 0'
  end

  test 'should require length to be an integer' do
    @product.shipping_length = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_length], 'must be an integer'
  end

  test 'should allow valid length' do
    @product.shipping_length = 100
    assert @product.valid?
  end

  # Width validations
  test 'should allow nil width' do
    @product.shipping_width = nil
    assert @product.valid?
  end

  test 'should require width to be a number when present' do
    @product.shipping_width = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_width], 'is not a number'
  end

  test 'should require width to be greater than zero when present' do
    @product.shipping_width = 0
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_width], 'must be greater than 0'
  end

  test 'should not allow negative width' do
    @product.shipping_width = -1
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_width], 'must be greater than 0'
  end

  test 'should require width to be an integer' do
    @product.shipping_width = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_width], 'must be an integer'
  end

  test 'should allow valid width' do
    @product.shipping_width = 100
    assert @product.valid?
  end

  # Height validations
  test 'should allow nil height' do
    @product.shipping_height = nil
    assert @product.valid?
  end

  test 'should require height to be a number when present' do
    @product.shipping_height = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_height], 'is not a number'
  end

  test 'should require height to be greater than zero when present' do
    @product.shipping_height = 0
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_height], 'must be greater than 0'
  end

  test 'should not allow negative height' do
    @product.shipping_height = -1
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_height], 'must be greater than 0'
  end

  test 'should require height to be an integer' do
    @product.shipping_height = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:shipping_height], 'must be an integer'
  end

  test 'should allow valid height' do
    @product.shipping_height = 5
    assert @product.valid?
  end

  # Category association validation
  test 'should require category' do
    @product.category = nil
    assert_not @product.valid?
    assert_includes @product.errors[:category], 'must exist'
  end

  # Scope tests
  test 'active scope returns only active products' do
    active_products = Product.active
    assert active_products.all?(&:active)
    assert active_products.include?(products(:product_one))
  end

  test 'in_price_range scope filters by min price' do
    products_above_min = Product.in_price_range(1800, nil)
    products_above_min.each do |product|
      assert product.price >= 1800
    end
  end

  test 'in_price_range scope filters by max price' do
    products_below_max = Product.in_price_range(nil, 2000)
    products_below_max.each do |product|
      assert product.price <= 2000
    end
  end

  test 'in_price_range scope filters by min and max price' do
    products_in_range = Product.in_price_range(1500, 2000)
    products_in_range.each do |product|
      assert product.price >= 1500
      assert product.price <= 2000
    end
  end

  test 'in_price_range scope returns all products when no range specified' do
    all_products = Product.in_price_range(nil, nil)
    assert_equal Product.count, all_products.count
  end

  test 'in_price_range scope handles empty string parameters' do
    all_products = Product.in_price_range('', '')
    assert_equal Product.count, all_products.count
  end

  test 'active and in_price_range scopes can be chained' do
    filtered_products = Product.active.in_price_range(1500, 2000)
    filtered_products.each do |product|
      assert product.active
      assert product.price >= 1500
      assert product.price <= 2000
    end
  end
end
