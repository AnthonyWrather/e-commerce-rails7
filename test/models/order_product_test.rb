# frozen_string_literal: true

require 'test_helper'

class OrderProductTest < ActiveSupport::TestCase
  def setup
    @product = products(:product_one)
    @order = orders(:order_one)
    @order_product = OrderProduct.new(
      product: @product,
      order: @order,
      quantity: 2,
      price: 15_000
    )
  end

  # Basic validity test
  test 'should be valid with all required attributes' do
    assert @order_product.valid?
  end

  # Product association validation
  test 'should require product' do
    @order_product.product = nil
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:product], 'must exist'
  end

  # Order association validation
  test 'should require order' do
    @order_product.order = nil
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:order], 'must exist'
  end

  # Quantity validations
  test 'should require quantity' do
    @order_product.quantity = nil
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:quantity], "can't be blank"
  end

  test 'should require quantity to be a number' do
    @order_product.quantity = 'not a number'
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:quantity], 'is not a number'
  end

  test 'should require quantity to be greater than zero' do
    @order_product.quantity = 0
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:quantity], 'must be greater than 0'
  end

  test 'should not allow negative quantity' do
    @order_product.quantity = -1
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:quantity], 'must be greater than 0'
  end

  test 'should require quantity to be an integer' do
    @order_product.quantity = 2.5
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:quantity], 'must be an integer'
  end

  test 'should allow valid quantity' do
    @order_product.quantity = 5
    assert @order_product.valid?
  end

  # Price validations
  test 'should require price' do
    @order_product.price = nil
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:price], "can't be blank"
  end

  test 'should require price to be a number' do
    @order_product.price = 'not a number'
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:price], 'is not a number'
  end

  test 'should require price to be greater than or equal to zero' do
    @order_product.price = -1
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:price], 'must be greater than or equal to 0'
  end

  test 'should allow price of zero' do
    @order_product.price = 0
    assert @order_product.valid?
  end

  test 'should require price to be an integer' do
    @order_product.price = 10.5
    assert_not @order_product.valid?
    assert_includes @order_product.errors[:price], 'must be an integer'
  end

  test 'should allow valid price' do
    @order_product.price = 25_000
    assert @order_product.valid?
  end

  # Size validation
  test 'should allow nil size' do
    @order_product.size = nil
    assert @order_product.valid?
  end

  test 'should allow empty size' do
    @order_product.size = ''
    assert @order_product.valid?
  end

  test 'should allow valid size' do
    @order_product.size = '1m x 10m Roll'
    assert @order_product.valid?
  end
end
