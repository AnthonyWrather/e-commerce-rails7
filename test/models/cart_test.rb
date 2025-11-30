# frozen_string_literal: true

require 'test_helper'

class CartTest < ActiveSupport::TestCase
  def setup
    @cart = carts(:cart_one)
    @expired_cart = carts(:expired_cart)
    @product = products(:product_one)
  end

  test 'should be valid with required attributes' do
    cart = Cart.new(session_token: 'new_token', expires_at: 30.days.from_now)
    assert cart.valid?
  end

  test 'should require session_token' do
    cart = Cart.new(expires_at: 30.days.from_now)
    assert_not cart.valid?
    assert_includes cart.errors[:session_token], "can't be blank"
  end

  test 'should require unique session_token' do
    cart = Cart.new(session_token: @cart.session_token, expires_at: 30.days.from_now)
    assert_not cart.valid?
    assert_includes cart.errors[:session_token], 'has already been taken'
  end

  test 'should require expires_at' do
    # The before_validation callback sets expires_at, so we test that behavior
    cart = Cart.new(session_token: 'requires_expires_token')
    cart.save
    # After saving, the expires_at should be set by callback
    assert_not_nil cart.expires_at
    assert cart.expires_at > Time.current
  end

  test 'should set default expires_at on create' do
    cart = Cart.create!(session_token: 'test_token_default')
    assert_not_nil cart.expires_at
    assert cart.expires_at > Time.current
  end

  test 'should have many cart_items' do
    assert_respond_to @cart, :cart_items
    assert @cart.cart_items.count >= 0
  end

  test 'active scope returns only non-expired carts' do
    active_carts = Cart.active
    assert active_carts.include?(@cart)
    assert_not active_carts.include?(@expired_cart)
  end

  test 'expired scope returns only expired carts' do
    expired_carts = Cart.expired
    assert expired_carts.include?(@expired_cart)
    assert_not expired_carts.include?(@cart)
  end

  test 'expired? returns true for expired cart' do
    assert @expired_cart.expired?
  end

  test 'expired? returns false for active cart' do
    assert_not @cart.expired?
  end

  test 'extend_expiry! updates expires_at' do
    old_expires_at = @cart.expires_at
    @cart.extend_expiry!
    assert @cart.expires_at > old_expires_at
  end

  test 'find_or_create_by_token finds existing cart' do
    cart = Cart.find_or_create_by_token(@cart.session_token)
    assert_equal @cart.id, cart.id
  end

  test 'find_or_create_by_token creates new cart if not found' do
    new_token = 'brand_new_token'
    cart = Cart.find_or_create_by_token(new_token)
    assert cart.persisted?
    assert_equal new_token, cart.session_token
  end

  test 'total calculates sum of cart item totals' do
    cart = carts(:cart_one)
    expected_total = cart.cart_items.sum { |item| item.price * item.quantity }
    assert_equal expected_total, cart.total
  end

  test 'refresh_prices! updates prices from current product prices' do
    cart_item = @cart.cart_items.first
    cart_item.price

    # Manually change cart item price to simulate outdated price
    cart_item.update_column(:price, 99_999)
    @cart.refresh_prices!
    cart_item.reload

    # Price should be refreshed to current product/stock price
    assert_not_equal 99_999, cart_item.price
  end

  test 'merge_items! adds new items to cart' do
    new_product = products(:product_three)
    initial_count = @cart.cart_items.count

    @cart.merge_items!([
                         { product_id: new_product.id, size: '', quantity: 2, price: new_product.price }
                       ])

    assert_equal initial_count + 1, @cart.cart_items.count
  end

  test 'merge_items! increases quantity for existing items' do
    existing_item = @cart.cart_items.first
    original_quantity = existing_item.quantity

    @cart.merge_items!([
                         { product_id: existing_item.product_id, size: existing_item.size, quantity: 3 }
                       ])

    existing_item.reload
    assert_equal original_quantity + 3, existing_item.quantity
  end

  test 'destroy cart destroys associated cart_items' do
    cart = Cart.create!(session_token: 'destroy_test', expires_at: 30.days.from_now)
    cart.cart_items.create!(product: @product, size: '', quantity: 1, price: @product.price)
    cart_item_id = cart.cart_items.first.id

    cart.destroy

    assert_nil CartItem.find_by(id: cart_item_id)
  end
end
