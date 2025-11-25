# frozen_string_literal: true

require 'test_helper'

class StockTest < ActiveSupport::TestCase
  def setup
    @product = products(:product_one)
    @stock = Stock.new(
      size: '1m x 10m Roll',
      stock_level: 50,
      price: 15_000,
      weight: 3000,
      length: 1000,
      width: 100,
      height: 10,
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
    @stock.weight = nil
    assert @stock.valid?
  end

  test 'should require weight to be a number when present' do
    @stock.weight = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:weight], 'is not a number'
  end

  test 'should require weight to be greater than zero when present' do
    @stock.weight = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:weight], 'must be greater than 0'
  end

  test 'should not allow negative weight' do
    @stock.weight = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:weight], 'must be greater than 0'
  end

  test 'should require weight to be an integer' do
    @stock.weight = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:weight], 'must be an integer'
  end

  test 'should allow valid weight' do
    @stock.weight = 4000
    assert @stock.valid?
  end

  # Length validations
  test 'should allow nil length' do
    @stock.length = nil
    assert @stock.valid?
  end

  test 'should require length to be a number when present' do
    @stock.length = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:length], 'is not a number'
  end

  test 'should require length to be greater than zero when present' do
    @stock.length = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:length], 'must be greater than 0'
  end

  test 'should not allow negative length' do
    @stock.length = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:length], 'must be greater than 0'
  end

  test 'should require length to be an integer' do
    @stock.length = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:length], 'must be an integer'
  end

  test 'should allow valid length' do
    @stock.length = 2000
    assert @stock.valid?
  end

  # Width validations
  test 'should allow nil width' do
    @stock.width = nil
    assert @stock.valid?
  end

  test 'should require width to be a number when present' do
    @stock.width = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:width], 'is not a number'
  end

  test 'should require width to be greater than zero when present' do
    @stock.width = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:width], 'must be greater than 0'
  end

  test 'should not allow negative width' do
    @stock.width = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:width], 'must be greater than 0'
  end

  test 'should require width to be an integer' do
    @stock.width = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:width], 'must be an integer'
  end

  test 'should allow valid width' do
    @stock.width = 150
    assert @stock.valid?
  end

  # Height validations
  test 'should allow nil height' do
    @stock.height = nil
    assert @stock.valid?
  end

  test 'should require height to be a number when present' do
    @stock.height = 'not a number'
    assert_not @stock.valid?
    assert_includes @stock.errors[:height], 'is not a number'
  end

  test 'should require height to be greater than zero when present' do
    @stock.height = 0
    assert_not @stock.valid?
    assert_includes @stock.errors[:height], 'must be greater than 0'
  end

  test 'should not allow negative height' do
    @stock.height = -1
    assert_not @stock.valid?
    assert_includes @stock.errors[:height], 'must be greater than 0'
  end

  test 'should require height to be an integer' do
    @stock.height = 10.5
    assert_not @stock.valid?
    assert_includes @stock.errors[:height], 'must be an integer'
  end

  test 'should allow valid height' do
    @stock.height = 15
    assert @stock.valid?
  end

  # Product association validation
  test 'should require product' do
    @stock.product = nil
    assert_not @stock.valid?
    assert_includes @stock.errors[:product], 'must exist'
  end
end
