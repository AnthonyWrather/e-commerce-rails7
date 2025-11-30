# frozen_string_literal: true

require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  def setup
    @cart = carts(:cart_one)
    @product = products(:product_one)
    @stock = stocks(:stock_one)
    @cart_item = cart_items(:cart_item_one)
    @cart_item_without_stock = cart_items(:cart_item_two)
  end

  test 'should be valid with required attributes' do
    cart_item = CartItem.new(
      cart: carts(:cart_two),
      product: @product,
      size: 'new_size',
      quantity: 1,
      price: 1000
    )
    assert cart_item.valid?
  end

  test 'should require cart' do
    cart_item = CartItem.new(product: @product, quantity: 1, price: 1000)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:cart], 'must exist'
  end

  test 'should require product' do
    cart_item = CartItem.new(cart: @cart, quantity: 1, price: 1000)
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:product], 'must exist'
  end

  test 'should allow optional stock' do
    cart_item = CartItem.new(
      cart: carts(:cart_two),
      product: @product,
      size: 'size_without_stock',
      quantity: 1,
      price: 1000
    )
    assert cart_item.valid?
  end

  test 'should require quantity' do
    cart_item = CartItem.new(cart: @cart, product: @product, price: 1000, size: 'test_size')
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:quantity], "can't be blank"
  end

  test 'should require quantity greater than zero' do
    cart_item = CartItem.new(cart: carts(:cart_two), product: @product, quantity: 0, price: 1000, size: 'test_size')
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:quantity], 'must be greater than 0'
  end

  test 'should require positive integer quantity' do
    cart_item = CartItem.new(cart: carts(:cart_two), product: @product, quantity: -1, price: 1000, size: 'test_size')
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:quantity], 'must be greater than 0'
  end

  test 'should require price' do
    cart_item = CartItem.new(cart: @cart, product: @product, quantity: 1, size: 'test_size')
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:price], "can't be blank"
  end

  test 'should require price to be non-negative' do
    cart_item = CartItem.new(cart: carts(:cart_two), product: @product, quantity: 1, price: -1, size: 'test_size')
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:price], 'must be greater than or equal to 0'
  end

  test 'should not allow duplicate product_id with same cart_id and size' do
    cart_item = CartItem.new(
      cart: @cart_item.cart,
      product: @cart_item.product,
      size: @cart_item.size,
      quantity: 1,
      price: 1000
    )
    assert_not cart_item.valid?
    assert_includes cart_item.errors[:product_id], 'already in cart with this size'
  end

  test 'name returns product name' do
    assert_equal @product.name, @cart_item.name
  end

  test 'total returns price times quantity' do
    expected = @cart_item.price * @cart_item.quantity
    assert_equal expected, @cart_item.total
  end

  test 'refresh_price! updates price from stock when stock present' do
    @cart_item.update_column(:price, 99_999)
    @cart_item.refresh_price!
    assert_equal @stock.price, @cart_item.price
  end

  test 'refresh_price! updates price from product when no stock' do
    product = @cart_item_without_stock.product
    @cart_item_without_stock.update_column(:price, 99_999)
    @cart_item_without_stock.refresh_price!
    assert_equal product.price, @cart_item_without_stock.price
  end

  test 'stock_available? returns true when sufficient stock from stock' do
    @stock.update!(stock_level: 100)
    @cart_item.update!(quantity: 10)
    assert @cart_item.stock_available?
  end

  test 'stock_available? returns false when insufficient stock from stock' do
    @stock.update!(stock_level: 1)
    @cart_item.update!(quantity: 10)
    assert_not @cart_item.stock_available?
  end

  test 'stock_available? returns true when sufficient stock from product' do
    @cart_item_without_stock.product.update!(stock_level: 100)
    @cart_item_without_stock.update!(quantity: 10)
    assert @cart_item_without_stock.stock_available?
  end

  test 'stock_available? returns false when insufficient stock from product' do
    @cart_item_without_stock.product.update!(stock_level: 1)
    @cart_item_without_stock.update!(quantity: 10)
    assert_not @cart_item_without_stock.stock_available?
  end
end
