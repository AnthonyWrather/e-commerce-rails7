# frozen_string_literal: true

require 'test_helper'

class CartPersistenceServiceTest < ActiveSupport::TestCase
  def setup
    @cart = carts(:cart_one)
    @product = products(:product_one)
    @product_two = products(:product_two)
    @stock = stocks(:stock_one)
  end

  test 'initialize creates new cart if token not found' do
    service = CartPersistenceService.new('brand_new_token')
    assert service.cart.persisted?
    assert_equal 'brand_new_token', service.cart.session_token
  end

  test 'initialize finds existing cart by token' do
    service = CartPersistenceService.new(@cart.session_token)
    assert_equal @cart.id, service.cart.id
  end

  test 'sync_from_local_storage creates cart items' do
    service = CartPersistenceService.new('sync_test_token')
    items_data = [
      { 'id' => @product.id, 'name' => @product.name, 'price' => @product.price, 'size' => '', 'quantity' => 2 }
    ]

    service.sync_from_local_storage(items_data)

    assert_equal 1, service.cart.cart_items.count
    item = service.cart.cart_items.first
    assert_equal @product.id, item.product_id
    assert_equal 2, item.quantity
  end

  test 'sync_from_local_storage updates existing cart items' do
    service = CartPersistenceService.new(@cart.session_token)
    existing_item = @cart.cart_items.first
    items_data = [
      { 'id' => existing_item.product_id, 'size' => existing_item.size, 'quantity' => 100 }
    ]

    service.sync_from_local_storage(items_data)

    existing_item.reload
    assert_equal 100, existing_item.quantity
  end

  test 'sync_from_local_storage uses current price from stock' do
    service = CartPersistenceService.new('price_sync_token')
    items_data = [
      { 'id' => @product.id, 'size' => @stock.size, 'quantity' => 1, 'price' => 99999 }
    ]

    service.sync_from_local_storage(items_data)

    item = service.cart.cart_items.first
    assert_equal @stock.price, item.price
  end

  test 'sync_from_local_storage uses current price from product when no stock' do
    service = CartPersistenceService.new('price_sync_product_token')
    items_data = [
      { 'id' => @product_two.id, 'size' => '', 'quantity' => 1, 'price' => 99999 }
    ]

    service.sync_from_local_storage(items_data)

    item = service.cart.cart_items.first
    assert_equal @product_two.price, item.price
  end

  test 'sync_from_local_storage extends cart expiry' do
    service = CartPersistenceService.new(@cart.session_token)
    old_expires_at = @cart.expires_at

    service.sync_from_local_storage([])

    @cart.reload
    assert @cart.expires_at > old_expires_at
  end

  test 'sync_from_local_storage ignores invalid product ids' do
    service = CartPersistenceService.new('invalid_product_token')
    items_data = [
      { 'id' => 999_999, 'size' => '', 'quantity' => 1 }
    ]

    service.sync_from_local_storage(items_data)

    assert_equal 0, service.cart.cart_items.count
  end

  test 'load_cart returns nil for expired cart' do
    expired_cart = carts(:expired_cart)
    service = CartPersistenceService.new(expired_cart.session_token)

    result = service.load_cart

    assert_nil result
  end

  test 'load_cart returns cart for active cart' do
    service = CartPersistenceService.new(@cart.session_token)

    result = service.load_cart

    assert_equal @cart.id, result.id
  end

  test 'load_cart refreshes prices' do
    cart_item = @cart.cart_items.first
    cart_item.update_column(:price, 99999)

    service = CartPersistenceService.new(@cart.session_token)
    service.load_cart

    cart_item.reload
    assert_not_equal 99999, cart_item.price
  end

  test 'to_local_storage_format returns array of item hashes' do
    service = CartPersistenceService.new(@cart.session_token)

    result = service.to_local_storage_format

    assert result.is_a?(Array)
    assert result.any?

    first_item = result.first
    assert first_item.key?(:id)
    assert first_item.key?(:name)
    assert first_item.key?(:price)
    assert first_item.key?(:size)
    assert first_item.key?(:quantity)
  end

  test 'merge_carts adds new items' do
    service = CartPersistenceService.new(@cart.session_token)
    initial_count = @cart.cart_items.count

    incoming_items = [
      { product_id: @product_two.id, size: 'new_size', quantity: 3, price: @product_two.price }
    ]

    service.merge_carts(incoming_items)

    assert_equal initial_count + 1, service.cart.cart_items.count
  end

  test 'merge_carts increases quantity for existing items' do
    service = CartPersistenceService.new(@cart.session_token)
    existing_item = @cart.cart_items.first
    original_quantity = existing_item.quantity

    incoming_items = [
      { product_id: existing_item.product_id, size: existing_item.size, quantity: 5 }
    ]

    service.merge_carts(incoming_items)

    existing_item.reload
    assert_equal original_quantity + 5, existing_item.quantity
  end

  test 'clear_cart removes all cart items' do
    service = CartPersistenceService.new(@cart.session_token)
    assert @cart.cart_items.any?

    service.clear_cart

    assert @cart.cart_items.reload.empty?
  end
end
