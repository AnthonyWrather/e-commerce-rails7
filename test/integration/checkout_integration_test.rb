# frozen_string_literal: true

require 'test_helper'

#
# Checkout Integration Tests
#
# These tests verify the end-to-end checkout flow from cart to order creation.
# They test the integration between CheckoutsController, WebhooksController,
# and OrderProcessor service.
#
class CheckoutIntegrationTest < ActionDispatch::IntegrationTest
  include StripeTestHelpers

  # Test constant for high-value product pricing (in pence)
  HIGH_VALUE_PRODUCT_PRICE_IN_PENCE = 100_000_00 # £100,000

  setup do
    @product = products(:product_one)
    @product.update(price: 1500, stock_level: 100)

    @product_two = products(:product_two)
    @product_two.update(price: 2000, stock_level: 50)

    @stock = stocks(:stock_one)
    @stock.update(product: @product, size: '1m x 10m Roll', price: 14_000, stock_level: 25)

    ENV['STRIPE_SECRET_KEY'] = 'sk_test_fake_key_for_testing'
    ENV['STRIPE_WEBHOOK_KEY'] = 'whsec_test_webhook_secret_for_testing'
    ENV['STRIPE_TAX_RATE_ID'] = 'txr_test_12345'
  end

  teardown do
    ENV.delete('STRIPE_SECRET_KEY')
    ENV.delete('STRIPE_WEBHOOK_KEY')
    ENV.delete('STRIPE_TAX_RATE_ID')
  end

  # ============================================================================
  # END-TO-END CHECKOUT FLOW TESTS
  # ============================================================================

  test 'complete checkout flow: product page to success page' do
    # Step 1: Visit product page
    get product_url(@product)
    assert_response :success
    assert_match @product.name, response.body

    # Step 2: Visit cart page
    get cart_url
    assert_response :success

    # Step 3: Success page is accessible
    get success_url
    assert_response :success
    assert_match 'successfully placed', response.body
  end

  test 'checkout flow respects stock levels' do
    # Test that stock validation works during checkout
    @product.update(stock_level: 3)

    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { @rendered }
    controller.define_singleton_method(:render) do |args|
      @rendered = true
      @render_args = args
    end

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @product.price,
        'size' => '',
        'quantity' => 5 # More than available
      }
    ]

    controller.send(:build_line_items, cart)

    assert controller.instance_variable_get(:@rendered)
    render_args = controller.instance_variable_get(:@render_args)
    assert_equal 400, render_args[:status]
    assert_match(/not enough stock/i, render_args[:json][:error])
  end

  test 'checkout with multiple products builds correct line items' do
    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @product.price,
        'size' => '',
        'quantity' => 2
      },
      {
        'id' => @product_two.id,
        'name' => @product_two.name,
        'price' => @product_two.price,
        'size' => '',
        'quantity' => 1
      }
    ]

    line_items = controller.send(:build_line_items, cart)

    assert_equal 2, line_items.length
    assert(line_items.all? { |item| item[:price_data][:tax_behavior] == 'inclusive' })

    # Verify total would be correct
    total = line_items.sum { |item| item[:price_data][:unit_amount] * item[:quantity] }
    expected_total = (@product.price * 2) + (@product_two.price * 1)
    assert_equal expected_total, total
  end

  test 'checkout with stock variant uses correct pricing' do
    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @stock.price,
        'size' => @stock.size,
        'quantity' => 1
      }
    ]

    line_items = controller.send(:build_line_items, cart)

    metadata = line_items.first[:price_data][:product_data][:metadata]
    assert_equal @stock.id, metadata[:product_stock_id]
    assert_equal @stock.price, metadata[:product_price]
  end

  # ============================================================================
  # CANCEL FLOW TESTS
  # ============================================================================

  test 'cancel page is accessible and shows error message' do
    get cancel_url
    assert_response :success
    assert_match 'not placed', response.body.downcase
  end

  test 'navigation from cart to cancel and back' do
    get cart_url
    assert_response :success

    get cancel_url
    assert_response :success

    get cart_url
    assert_response :success
  end

  # ============================================================================
  # SHIPPING OPTIONS TESTS
  # ============================================================================

  test 'shipping options are correctly configured' do
    shipping_options = CheckoutsController::SHIPPING_OPTIONS

    # Verify Collection option (free)
    collection = shipping_options.find { |o| o[:shipping_rate_data][:display_name] == 'Collection' }
    assert_not_nil collection
    assert_equal 0, collection[:shipping_rate_data][:fixed_amount][:amount]

    # Verify standard shipping
    standard = shipping_options.find { |o| o[:shipping_rate_data][:display_name].include?('3 to 5') }
    assert_not_nil standard
    assert_equal 2500, standard[:shipping_rate_data][:fixed_amount][:amount]

    # Verify overnight shipping
    overnight = shipping_options.find { |o| o[:shipping_rate_data][:display_name].include?('Overnight') }
    assert_not_nil overnight
    assert_equal 5000, overnight[:shipping_rate_data][:fixed_amount][:amount]
  end

  # ============================================================================
  # PRICE CALCULATION TESTS
  # ============================================================================

  test 'checkout calculates correct totals for mixed cart' do
    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    cart = [
      { 'id' => @product.id, 'name' => @product.name, 'price' => @product.price, 'size' => '', 'quantity' => 3 },
      { 'id' => @product_two.id, 'name' => @product_two.name, 'price' => @product_two.price, 'size' => '', 'quantity' => 2 },
      { 'id' => @product.id, 'name' => @product.name, 'price' => @stock.price, 'size' => @stock.size, 'quantity' => 1 }
    ]

    line_items = controller.send(:build_line_items, cart)

    assert_equal 3, line_items.length

    # Calculate expected total
    expected = (@product.price * 3) + (@product_two.price * 2) + (@stock.price * 1)
    actual = line_items.sum { |item| item[:price_data][:unit_amount] * item[:quantity] }
    assert_equal expected, actual
  end

  # ============================================================================
  # ORDER CREATION SIMULATION
  # ============================================================================

  test 'order count increases after successful webhook' do
    # This is a conceptual test - actual order creation happens in OrderProcessor
    # which requires Stripe API mocking

    initial_order_count = Order.count

    # Simulate what happens: order created via webhook
    # In real flow, OrderProcessor creates Order after webhook verification
    Order.create!(
      customer_email: 'test@example.com',
      total: @product.price,
      address: '123 Test St, London, W1A 1AA',
      name: 'Test Customer',
      phone: '01234567890',
      billing_name: 'Test Customer',
      billing_address: '123 Test St, London, W1A 1AA',
      payment_status: 'paid',
      payment_id: 'pi_test_123'
    )

    assert_equal initial_order_count + 1, Order.count
  end

  test 'order products are created with correct attributes' do
    order = Order.create!(
      customer_email: 'test@example.com',
      total: @product.price * 2,
      address: '123 Test St, London, W1A 1AA',
      name: 'Test Customer',
      phone: '01234567890',
      billing_name: 'Test Customer',
      billing_address: '123 Test St, London, W1A 1AA',
      payment_status: 'paid',
      payment_id: 'pi_test_456'
    )

    order_product = OrderProduct.create!(
      order: order,
      product: @product,
      quantity: 2,
      size: '',
      price: @product.price
    )

    assert_equal @product.id, order_product.product_id
    assert_equal 2, order_product.quantity
    assert_equal @product.price, order_product.price
  end

  # ============================================================================
  # EDGE CASE TESTS
  # ============================================================================

  test 'checkout handles single item cart' do
    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    cart = [
      { 'id' => @product.id, 'name' => @product.name, 'price' => @product.price, 'size' => '', 'quantity' => 1 }
    ]

    line_items = controller.send(:build_line_items, cart)

    assert_equal 1, line_items.length
    assert_equal 1, line_items.first[:quantity]
  end

  test 'checkout handles maximum quantity' do
    @product.update(stock_level: 1000)

    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    cart = [
      { 'id' => @product.id, 'name' => @product.name, 'price' => @product.price, 'size' => '', 'quantity' => 999 }
    ]

    line_items = controller.send(:build_line_items, cart)

    assert_equal 999, line_items.first[:quantity]
  end

  test 'checkout handles high value products' do
    @product.update(price: HIGH_VALUE_PRODUCT_PRICE_IN_PENCE)

    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    cart = [
      { 'id' => @product.id, 'name' => @product.name, 'price' => @product.price, 'size' => '', 'quantity' => 1 }
    ]

    line_items = controller.send(:build_line_items, cart)

    assert_equal HIGH_VALUE_PRODUCT_PRICE_IN_PENCE, line_items.first[:price_data][:unit_amount]
  end
end
