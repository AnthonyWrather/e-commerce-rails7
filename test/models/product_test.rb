# frozen_string_literal: true

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  def setup
    @category = categories(:category_one)
    @product = Product.new(
      name: 'Test Product',
      price: 1000,
      stock_level: 50,
      weight: 300,
      length: 100,
      width: 100,
      height: 5,
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
    @product.weight = nil
    assert @product.valid?
  end

  test 'should require weight to be a number when present' do
    @product.weight = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:weight], 'is not a number'
  end

  test 'should require weight to be greater than zero when present' do
    @product.weight = 0
    assert_not @product.valid?
    assert_includes @product.errors[:weight], 'must be greater than 0'
  end

  test 'should not allow negative weight' do
    @product.weight = -1
    assert_not @product.valid?
    assert_includes @product.errors[:weight], 'must be greater than 0'
  end

  test 'should require weight to be an integer' do
    @product.weight = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:weight], 'must be an integer'
  end

  test 'should allow valid weight' do
    @product.weight = 300
    assert @product.valid?
  end

  # Length validations
  test 'should allow nil length' do
    @product.length = nil
    assert @product.valid?
  end

  test 'should require length to be a number when present' do
    @product.length = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:length], 'is not a number'
  end

  test 'should require length to be greater than zero when present' do
    @product.length = 0
    assert_not @product.valid?
    assert_includes @product.errors[:length], 'must be greater than 0'
  end

  test 'should not allow negative length' do
    @product.length = -1
    assert_not @product.valid?
    assert_includes @product.errors[:length], 'must be greater than 0'
  end

  test 'should require length to be an integer' do
    @product.length = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:length], 'must be an integer'
  end

  test 'should allow valid length' do
    @product.length = 100
    assert @product.valid?
  end

  # Width validations
  test 'should allow nil width' do
    @product.width = nil
    assert @product.valid?
  end

  test 'should require width to be a number when present' do
    @product.width = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:width], 'is not a number'
  end

  test 'should require width to be greater than zero when present' do
    @product.width = 0
    assert_not @product.valid?
    assert_includes @product.errors[:width], 'must be greater than 0'
  end

  test 'should not allow negative width' do
    @product.width = -1
    assert_not @product.valid?
    assert_includes @product.errors[:width], 'must be greater than 0'
  end

  test 'should require width to be an integer' do
    @product.width = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:width], 'must be an integer'
  end

  test 'should allow valid width' do
    @product.width = 100
    assert @product.valid?
  end

  # Height validations
  test 'should allow nil height' do
    @product.height = nil
    assert @product.valid?
  end

  test 'should require height to be a number when present' do
    @product.height = 'not a number'
    assert_not @product.valid?
    assert_includes @product.errors[:height], 'is not a number'
  end

  test 'should require height to be greater than zero when present' do
    @product.height = 0
    assert_not @product.valid?
    assert_includes @product.errors[:height], 'must be greater than 0'
  end

  test 'should not allow negative height' do
    @product.height = -1
    assert_not @product.valid?
    assert_includes @product.errors[:height], 'must be greater than 0'
  end

  test 'should require height to be an integer' do
    @product.height = 10.5
    assert_not @product.valid?
    assert_includes @product.errors[:height], 'must be an integer'
  end

  test 'should allow valid height' do
    @product.height = 5
    assert @product.valid?
  end

  # Category association validation
  test 'should require category' do
    @product.category = nil
    assert_not @product.valid?
    assert_includes @product.errors[:category], 'must exist'
  end
end
