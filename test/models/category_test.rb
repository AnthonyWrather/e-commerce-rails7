# frozen_string_literal: true

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  def setup
    @category = Category.new(
      name: 'Unique Test Category Name',
      description: 'A test category for validation'
    )
  end

  # Basic validity test
  test 'should be valid with all required attributes' do
    assert @category.valid?
  end

  # Name validations
  test 'should require name' do
    @category.name = nil
    assert_not @category.valid?
    assert_includes @category.errors[:name], "can't be blank"
  end

  test 'should require name to not be empty string' do
    @category.name = '   '
    assert_not @category.valid?
    assert_includes @category.errors[:name], "can't be blank"
  end

  test 'should allow valid name' do
    @category.name = 'Valid Category Name'
    assert @category.valid?
  end

  test 'should require unique name' do
    existing_category = categories(:category_one)
    @category.name = existing_category.name
    assert_not @category.valid?
    assert_includes @category.errors[:name], 'has already been taken'
  end

  test 'should require unique name case insensitively' do
    existing_category = categories(:category_one)
    @category.name = existing_category.name.upcase
    assert_not @category.valid?
    assert_includes @category.errors[:name], 'has already been taken'
  end

  # Description validations
  test 'should allow nil description' do
    @category.description = nil
    assert @category.valid?
  end

  test 'should allow empty description' do
    @category.description = ''
    assert @category.valid?
  end

  test 'should allow valid description' do
    @category.description = 'This is a valid description for the category'
    assert @category.valid?
  end

  # Association tests
  test 'should have many products' do
    category = categories(:category_one)
    assert_respond_to category, :products
    assert_kind_of ActiveRecord::Associations::CollectionProxy, category.products
  end

  test 'should destroy dependent products when category is destroyed' do
    # Use category_three which has no order dependencies
    category = categories(:category_three)

    # Create a test product for this category
    product = Product.create!(
      name: 'Test Product for Destruction',
      price: 1000,
      category: category,
      active: true
    )

    product_id = product.id

    category.destroy

    assert_nil Product.find_by(id: product_id), 'Product should be destroyed with category'
  end
end
