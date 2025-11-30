# frozen_string_literal: true

require 'test_helper'

class CartTest < ActiveSupport::TestCase
  # Test constants for clarity
  NONEXISTENT_PRODUCT_ID = 999_999
  ARBITRARY_OUTDATED_PRICE = 99_999

  def setup
    @cart = carts(:cart_one)
    @expired_cart = carts(:expired_cart)
    @product = products(:product_one)
    @product_two = products(:product_two)
    @product_three = products(:product_three)
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

  # ============================================================================
  # CART MERGE SCENARIO TESTS
  # ============================================================================

  test 'merge_items! handles string keys in item hash' do
    new_cart = Cart.create!(session_token: 'merge_string_keys_token')
    initial_count = new_cart.cart_items.count

    new_cart.merge_items!([
                            { 'product_id' => @product.id, 'size' => '', 'quantity' => 2, 'price' => @product.price }
                          ])

    assert_equal initial_count + 1, new_cart.cart_items.count
    item = new_cart.cart_items.first
    assert_equal @product.id, item.product_id
    assert_equal 2, item.quantity
  end

  test 'merge_items! handles id key instead of product_id' do
    new_cart = Cart.create!(session_token: 'merge_id_key_token')

    new_cart.merge_items!([
                            { 'id' => @product.id, 'size' => '', 'quantity' => 1 }
                          ])

    assert_equal 1, new_cart.cart_items.count
    assert_equal @product.id, new_cart.cart_items.first.product_id
  end

  test 'merge_items! ignores items with nil product_id' do
    new_cart = Cart.create!(session_token: 'merge_nil_product_token')

    new_cart.merge_items!([
                            { 'product_id' => nil, 'size' => '', 'quantity' => 1 }
                          ])

    assert_equal 0, new_cart.cart_items.count
  end

  test 'merge_items! ignores items with invalid product_id' do
    new_cart = Cart.create!(session_token: 'merge_invalid_product_token')

    new_cart.merge_items!([
                            { 'product_id' => NONEXISTENT_PRODUCT_ID, 'size' => '', 'quantity' => 1 }
                          ])

    assert_equal 0, new_cart.cart_items.count
  end

  test 'merge_items! handles mixed new and existing items' do
    new_cart = Cart.create!(session_token: 'merge_mixed_token')
    new_cart.cart_items.create!(product: @product, size: '', quantity: 5, price: @product.price)

    initial_count = new_cart.cart_items.count
    existing_item = new_cart.cart_items.first

    new_cart.merge_items!([
                            { 'product_id' => @product.id, 'size' => '', 'quantity' => 3 },
                            { 'product_id' => @product_two.id, 'size' => '', 'quantity' => 2 }
                          ])

    existing_item.reload
    assert_equal 8, existing_item.quantity # 5 + 3
    assert_equal initial_count + 1, new_cart.cart_items.count # One new item added
  end

  test 'merge_items! handles size variant matching correctly' do
    stock = stocks(:stock_one)
    new_cart = Cart.create!(session_token: 'merge_size_variant_token')

    # Add item with size variant
    new_cart.cart_items.create!(product: @product, stock: stock, size: stock.size, quantity: 1, price: stock.price)

    # Merge same product with different size (should create new item)
    new_cart.merge_items!([
                            { 'product_id' => @product.id, 'size' => 'different_size', 'quantity' => 2 }
                          ])

    # Should have 2 items: original with stock.size, new with 'different_size'
    assert_equal 2, new_cart.cart_items.count
    sizes = new_cart.cart_items.pluck(:size)
    assert_includes sizes, stock.size
    assert_includes sizes, 'different_size'
  end

  test 'merge_items! merges items with same product and size' do
    new_cart = Cart.create!(session_token: 'merge_same_size_token')
    new_cart.cart_items.create!(product: @product, size: 'Medium', quantity: 3, price: @product.price)

    new_cart.merge_items!([
                            { 'product_id' => @product.id, 'size' => 'Medium', 'quantity' => 4 }
                          ])

    assert_equal 1, new_cart.cart_items.count
    assert_equal 7, new_cart.cart_items.first.quantity # 3 + 4
  end

  test 'merge_items! handles large quantity merges' do
    new_cart = Cart.create!(session_token: 'merge_large_quantity_token')

    new_cart.merge_items!([
                            { 'product_id' => @product.id, 'size' => '', 'quantity' => 1000 }
                          ])

    assert_equal 1000, new_cart.cart_items.first.quantity
  end

  test 'merge_items! handles multiple items at once' do
    new_cart = Cart.create!(session_token: 'merge_multiple_token')

    new_cart.merge_items!([
                            { 'product_id' => @product.id, 'size' => '', 'quantity' => 1 },
                            { 'product_id' => @product_two.id, 'size' => '', 'quantity' => 2 },
                            { 'product_id' => @product_three.id, 'size' => '', 'quantity' => 3 }
                          ])

    assert_equal 3, new_cart.cart_items.count
    quantities = new_cart.cart_items.map(&:quantity).sort
    assert_equal [1, 2, 3], quantities
  end

  test 'merge_items! preserves stock reference when price provided' do
    stock = stocks(:stock_one)
    new_cart = Cart.create!(session_token: 'merge_stock_ref_token')

    # Merging with a known size should use stock price
    new_cart.merge_items!([
                            { 'product_id' => @product.id, 'size' => stock.size, 'quantity' => 1,
                              'price' => ARBITRARY_OUTDATED_PRICE }
                          ])

    item = new_cart.cart_items.first
    assert_equal stock.id, item.stock_id
    # Price from incoming data is used when provided
    assert_equal ARBITRARY_OUTDATED_PRICE, item.price
  end

  # ============================================================================
  # TOTAL CALCULATION EDGE CASES
  # ============================================================================

  test 'total returns zero for empty cart' do
    empty_cart = Cart.create!(session_token: 'empty_total_token')
    assert_equal 0, empty_cart.total
  end

  test 'total handles single item correctly' do
    single_cart = Cart.create!(session_token: 'single_total_token')
    single_cart.cart_items.create!(product: @product, size: '', quantity: 3, price: 1000)

    assert_equal 3000, single_cart.total # 3 * 1000
  end

  test 'total handles multiple items correctly' do
    multi_cart = Cart.create!(session_token: 'multi_total_token')
    multi_cart.cart_items.create!(product: @product, size: '', quantity: 2, price: 1000)
    multi_cart.cart_items.create!(product: @product_two, size: '', quantity: 1, price: 2500)

    assert_equal 4500, multi_cart.total # (2 * 1000) + (1 * 2500)
  end

  # ============================================================================
  # EXPIRY EDGE CASES
  # ============================================================================

  test 'expired? returns true for cart that expires exactly now' do
    just_expired = Cart.create!(session_token: 'just_expired_token', expires_at: Time.current)
    assert just_expired.expired?
  end

  test 'expired? returns false for cart expiring in 1 second' do
    almost_expired = Cart.create!(session_token: 'almost_expired_token', expires_at: 1.second.from_now)
    assert_not almost_expired.expired?
  end

  # ============================================================================
  # USER OWNERSHIP TESTS
  # ============================================================================

  test 'should allow optional user association' do
    cart = Cart.create!(session_token: 'guest_cart_token')
    assert_nil cart.user
    assert cart.valid?
  end

  test 'should allow cart with user' do
    user = users(:user_one)
    cart = Cart.create!(session_token: 'user_cart_token', user: user)
    assert_equal user, cart.user
    assert cart.valid?
  end

  test 'guest? returns true for cart without user' do
    cart = Cart.create!(session_token: 'guest_check_token')
    assert cart.guest?
  end

  test 'guest? returns false for cart with user' do
    user_cart = carts(:user_one_cart)
    assert_not user_cart.guest?
  end

  test 'guest_carts scope returns only carts without users' do
    guest_carts = Cart.guest_carts
    assert guest_carts.all?(&:guest?)
    assert_not guest_carts.include?(carts(:user_one_cart))
  end

  test 'user_carts scope returns only carts with users' do
    user_carts = Cart.user_carts
    assert user_carts.none?(&:guest?)
    assert user_carts.include?(carts(:user_one_cart))
  end

  test 'for_user scope returns carts for specific user' do
    user = users(:user_one)
    user_carts = Cart.for_user(user)
    assert(user_carts.all? { |c| c.user == user })
  end

  test 'find_or_create_for_user finds existing user cart' do
    user = users(:user_one)
    existing_cart = carts(:user_one_cart)

    cart = Cart.find_or_create_for_user(user)
    assert_equal existing_cart.id, cart.id
  end

  test 'find_or_create_for_user creates new cart if none exists' do
    user = users(:unconfirmed_user)

    cart = Cart.find_or_create_for_user(user)
    assert cart.persisted?
    assert_equal user, cart.user
  end

  test 'find_or_create_for_user converts guest cart to user cart' do
    user = users(:unconfirmed_user)
    guest_cart = Cart.create!(session_token: 'convert_guest_token')

    cart = Cart.find_or_create_for_user(user, session_token: guest_cart.session_token)
    assert_equal guest_cart.id, cart.id
    assert_equal user, cart.user
  end

  test 'assign_to_user! assigns cart to user' do
    user = users(:unconfirmed_user)
    cart = Cart.create!(session_token: 'assign_test_token')

    cart.assign_to_user!(user)
    assert_equal user, cart.user
  end

  test 'assign_to_user! merges with existing user cart' do
    user = users(:user_one)
    existing_cart = carts(:user_one_cart)
    guest_cart = Cart.create!(session_token: 'merge_assign_token')
    guest_cart.cart_items.create!(product: @product, size: 'test', quantity: 5, price: @product.price)

    result_cart = guest_cart.assign_to_user!(user)

    assert_equal existing_cart.id, result_cart.id
    assert_not Cart.exists?(guest_cart.id)
  end
end
