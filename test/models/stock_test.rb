# frozen_string_literal: true

require 'test_helper'

class StockTest < ActiveSupport::TestCase
  def setup
    @product = products(:product_one)
    @stock = Stock.new(
      size: '1m x 10m Roll',
      stock_level: 50,
      price: 15_000,
      shipping_weight: 3000,
      shipping_length: 1000,
      shipping_width: 100,
      shipping_height: 10,
      product: @product
    )
  end

  # Basic validity test
  test 'should be valid with all required attributes' do
    assert @stock.valid?
  end

  # Size validations
  test 'should require size' do
    @stock.size = nil
    assert_not @stock.valid?
    assert_includes @stock.errors[:size], "can't be blank"
  end

  test 'should require size to not be empty string' do
    @stock.size = '   '
    assert_not @stock.valid?
    assert_includes @stock.errors[:size], "can't be blank"
  end

  test 'should allow valid size' do
    @stock.size = '2m x 20m Roll'
    assert @stock.valid?
  end

  # Price validations
  test 'should require price' do
    @stock.price = nil
    assert_not @stock.valid?
    assert_includes @stock.errors[:price], "can't be blank"
  end

  test 'should require price to be a number' do
    @stock.price = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:price], 'is not a number'
  end

  test 'should require price to be greater than or equal to zero' do
    @stock.price = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:price], 'must be greater than or equal to 0'
  end

  test 'should allow price of zero' do
    @stock.price = 0
    assert @stock.valid?
  end

  test 'should require price to be an integer' do
    @stock.price = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:price], 'must be an integer'
  end

  test 'should allow valid price' do
    @stock.price = 20_000
    assert @stock.valid?
  end

  # Stock level validations
  test 'should allow nil stock_level' do
    @stock.stock_level = nil
    assert @stock.valid?
  end

  test 'should require stock_level to be a number when present' do
    @stock.stock_level = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:stock_level], 'is not a number'
  end

  test 'should require stock_level to be greater than or equal to zero' do
    @stock.stock_level = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:stock_level], 'must be greater than or equal to 0'
  end

  test 'should allow stock_level of zero' do
    @stock.stock_level = 0
    assert @stock.valid?
  end

  test 'should require stock_level to be an integer' do
    @stock.stock_level = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:stock_level], 'must be an integer'
  end

  test 'should allow valid stock_level' do
    @stock.stock_level = 100
    assert @stock.valid?
  end

  # Weight validations
  test 'should allow nil weight' do
    @stock.shipping_weight = nil
    assert @stock.valid?
  end

  test 'should require weight to be a number when present' do
    @stock.shipping_weight = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_weight], 'is not a number'
  end

  test 'should require weight to be greater than zero when present' do
    @stock.shipping_weight = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_weight], 'must be greater than 0'
  end

  test 'should not allow negative weight' do
    @stock.shipping_weight = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_weight], 'must be greater than 0'
  end

  test 'should require weight to be an integer' do
    @stock.shipping_weight = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_weight], 'must be an integer'
  end

  test 'should allow valid weight' do
    @stock.shipping_weight = 4000
    assert @stock.valid?
  end

  # Length validations
  test 'should allow nil length' do
    @stock.shipping_length = nil
    assert @stock.valid?
  end

  test 'should require length to be a number when present' do
    @stock.shipping_length = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_length], 'is not a number'
  end

  test 'should require length to be greater than zero when present' do
    @stock.shipping_length = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_length], 'must be greater than 0'
  end

  test 'should not allow negative length' do
    @stock.shipping_length = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_length], 'must be greater than 0'
  end

  test 'should require length to be an integer' do
    @stock.shipping_length = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_length], 'must be an integer'
  end

  test 'should allow valid length' do
    @stock.shipping_length = 2000
    assert @stock.valid?
  end

  # Width validations
  test 'should allow nil width' do
    @stock.shipping_width = nil
    assert @stock.valid?
  end

  test 'should require width to be a number when present' do
    @stock.shipping_width = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_width], 'is not a number'
  end

  test 'should require width to be greater than zero when present' do
    @stock.shipping_width = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_width], 'must be greater than 0'
  end

  test 'should not allow negative width' do
    @stock.shipping_width = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_width], 'must be greater than 0'
  end

  test 'should require width to be an integer' do
    @stock.shipping_width = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_width], 'must be an integer'
  end

  test 'should allow valid width' do
    @stock.shipping_width = 150
    assert @stock.valid?
  end

  # Height validations
  test 'should allow nil height' do
    @stock.shipping_height = nil
    assert @stock.valid?
  end

  test 'should require height to be a number when present' do
    @stock.shipping_height = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_height], 'is not a number'
  end

  test 'should require height to be greater than zero when present' do
    @stock.shipping_height = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_height], 'must be greater than 0'
  end

  test 'should not allow negative height' do
    @stock.shipping_height = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_height], 'must be greater than 0'
  end

  test 'should require height to be an integer' do
    @stock.shipping_height = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:shipping_height], 'must be an integer'
  end

  test 'should allow valid height' do
    @stock.shipping_height = 15
    assert @stock.valid?
  end

  # Product association validation
  test 'should require product' do
    @stock.product = nil
    assert_not @stock.valid?
    assert_includes @stock.errors[:product], 'must exist'
  end
end
