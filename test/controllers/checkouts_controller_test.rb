# frozen_string_literal: true

require 'test_helper'

class CheckoutsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:category_one)
    @product = products(:product_one)
    @product.update(price: 1200, stock_level: 10) # £12.00 inc VAT

    # Set up ENV for Stripe keys to avoid nil errors
    ENV['STRIPE_SECRET_KEY'] = 'sk_test_fake_key_for_testing'
    ENV['STRIPE_TAX_RATE_ID'] = 'txr_test_12345' # Use existing tax rate to avoid API call
  end

  teardown do
    ENV.delete('STRIPE_SECRET_KEY')
    ENV.delete('STRIPE_TAX_RATE_ID')
  end

  test 'should build line items with VAT tax behaviour' do
    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => 1200, # £12.00 inc VAT
        'size' => '',
        'quantity' => 2
      }
    ]

    controller = CheckoutsController.new

    # Test the private build_line_item method via build_line_items
    line_items = controller.send(:build_line_items, cart)

    assert_not_nil line_items
    assert_equal 1, line_items.compact.length

    line_item = line_items.first
    assert_equal 2, line_item[:quantity]
    assert_equal 1200, line_item[:price_data][:unit_amount]
    assert_equal 'gbp', line_item[:price_data][:currency]
    assert_equal 'inclusive', line_item[:price_data][:tax_behavior]
    assert_equal ['txr_test_12345'], line_item[:tax_rates]
  end

  test 'should handle missing tax rate ID gracefully' do
    ENV.delete('STRIPE_TAX_RATE_ID')

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => 1200,
        'size' => '',
        'quantity' => 1
      }
    ]

    controller = CheckoutsController.new

    # Stub the create_uk_vat_rate method to return nil (simulating API failure)
    controller.define_singleton_method(:create_uk_vat_rate) { nil }

    line_items = controller.send(:build_line_items, cart)
    line_item = line_items.first

    # Should have tax_behavior but no tax_rates array when tax_rate_id is nil
    assert_equal 'inclusive', line_item[:price_data][:tax_behavior]
    assert_nil line_item[:tax_rates]
  end

  test 'should create line items with correct pricing for stock variants' do
    # Product with stock variant
    stock = stocks(:stock_one)
    stock.update(product: @product, size: 'Large', price: 2400, stock_level: 10) # £24.00 inc VAT

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => 2400,
        'size' => 'Large',
        'quantity' => 1
      }
    ]

    controller = CheckoutsController.new
    line_items = controller.send(:build_line_items, cart)
    line_item = line_items.first

    # Verify the price is passed through correctly
    assert_equal 2400, line_item[:price_data][:unit_amount]
    assert_equal 'gbp', line_item[:price_data][:currency]
    assert_equal 'inclusive', line_item[:price_data][:tax_behavior]

    # Verify metadata includes product stock information
    metadata = line_item[:price_data][:product_data][:metadata]
    assert_equal @product.id, metadata[:product_id]
    assert_equal 'Large', metadata[:size]
    assert_equal stock.id, metadata[:product_stock_id]
  end

  test 'should use product price when no stock variant specified' do
    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @product.price,
        'size' => '',
        'quantity' => 1
      }
    ]

    controller = CheckoutsController.new
    line_items = controller.send(:build_line_items, cart)
    line_item = line_items.first

    # Should use product's price, not stock price
    assert_equal @product.price, line_item[:price_data][:unit_amount]
    assert_equal 'inclusive', line_item[:price_data][:tax_behavior]

    # Metadata should reference product_id for both product and stock
    metadata = line_item[:price_data][:product_data][:metadata]
    assert_equal @product.id, metadata[:product_id]
    assert_equal @product.id, metadata[:product_stock_id]
  end

  # ============================================================================
  # STOCK VALIDATION TESTS
  # ============================================================================

  test 'should detect insufficient stock for product without size variant' do
    @product.update(stock_level: 5)

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @product.price,
        'size' => '',
        'quantity' => 10
      }
    ]

    controller = CheckoutsController.new
    # Create a mock request for the controller context
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { @rendered }
    controller.define_singleton_method(:render) do |args|
      @rendered = true
      @render_args = args
    end

    controller.send(:build_line_items, cart)

    # line_items returns array with nil elements when stock validation fails
    # The map returns [nil] when the inner return is hit
    assert controller.instance_variable_get(:@rendered)
    render_args = controller.instance_variable_get(:@render_args)
    assert_match(/not enough stock/i, render_args[:json][:error])
    assert_equal 400, render_args[:status]
  end

  test 'should detect insufficient stock for stock variant' do
    stock = stocks(:stock_one)
    stock.update(product: @product, size: 'Large', price: 2400, stock_level: 3)

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => stock.price,
        'size' => 'Large',
        'quantity' => 5
      }
    ]

    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { @rendered }
    controller.define_singleton_method(:render) do |args|
      @rendered = true
      @render_args = args
    end

    controller.send(:build_line_items, cart)

    assert controller.instance_variable_get(:@rendered)
    render_args = controller.instance_variable_get(:@render_args)
    assert_match(/not enough stock/i, render_args[:json][:error])
    assert_match(/Large/, render_args[:json][:error])
  end

  test 'should allow checkout when stock is exactly sufficient' do
    @product.update(stock_level: 5)

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @product.price,
        'size' => '',
        'quantity' => 5
      }
    ]

    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    line_items = controller.send(:build_line_items, cart)
    line_item = line_items.first

    assert_not_nil line_item
    assert_equal 5, line_item[:quantity]
  end

  # ============================================================================
  # MULTIPLE ITEMS TESTS
  # ============================================================================

  test 'should build multiple line items for cart with multiple products' do
    product_two = products(:product_two)
    product_two.update(price: 2000, stock_level: 20)

    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @product.price,
        'size' => '',
        'quantity' => 2
      },
      {
        'id' => product_two.id,
        'name' => product_two.name,
        'price' => product_two.price,
        'size' => '',
        'quantity' => 3
      }
    ]

    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    line_items = controller.send(:build_line_items, cart)

    assert_equal 2, line_items.compact.length
    assert_equal 2, line_items[0][:quantity]
    assert_equal @product.price, line_items[0][:price_data][:unit_amount]
    assert_equal 3, line_items[1][:quantity]
    assert_equal product_two.price, line_items[1][:price_data][:unit_amount]
  end

  # ============================================================================
  # PRICING TESTS
  # ============================================================================

  test 'should get correct product pricing without stock variant' do
    controller = CheckoutsController.new
    item = { 'size' => '' }

    product_stock_id, price = controller.send(:get_product_pricing, @product, item)

    assert_equal @product.id, product_stock_id
    assert_equal @product.price, price
  end

  test 'should get correct stock pricing with size variant' do
    stock = stocks(:stock_one)
    stock.update(product: @product, size: 'XL', price: 5000)

    controller = CheckoutsController.new
    item = { 'size' => 'XL' }

    product_stock_id, price = controller.send(:get_product_pricing, @product, item)

    assert_equal stock.id, product_stock_id
    assert_equal 5000, price
  end

  # ============================================================================
  # SUCCESS AND CANCEL PAGES TESTS
  # ============================================================================

  test 'should get success page' do
    get success_url
    assert_response :success
  end

  test 'should render success template' do
    get success_url
    assert_template :success
  end

  test 'should get cancel page' do
    get cancel_url
    assert_response :success
  end

  test 'should render cancel template' do
    get cancel_url
    assert_template :cancel
  end

  # ============================================================================
  # SHIPPING OPTIONS TESTS
  # ============================================================================

  test 'SHIPPING_OPTIONS constant contains valid shipping configurations' do
    shipping_options = CheckoutsController::SHIPPING_OPTIONS

    assert_equal 3, shipping_options.length

    # Test Collection option
    collection = shipping_options[0]
    assert_equal 'Collection', collection[:shipping_rate_data][:display_name]
    assert_equal 0, collection[:shipping_rate_data][:fixed_amount][:amount]
    assert_equal 'gbp', collection[:shipping_rate_data][:fixed_amount][:currency]

    # Test 3-5 day shipping
    standard = shipping_options[1]
    assert_equal '3 to 5 Business Days Shipping', standard[:shipping_rate_data][:display_name]
    assert_equal 2500, standard[:shipping_rate_data][:fixed_amount][:amount]

    # Test overnight shipping
    overnight = shipping_options[2]
    assert_match(/overnight/i, overnight[:shipping_rate_data][:display_name])
    assert_equal 5000, overnight[:shipping_rate_data][:fixed_amount][:amount]
  end

  # ============================================================================
  # METADATA TESTS
  # ============================================================================

  test 'line item metadata contains all required fields' do
    cart = [
      {
        'id' => @product.id,
        'name' => @product.name,
        'price' => @product.price,
        'size' => '',
        'quantity' => 1
      }
    ]

    controller = CheckoutsController.new
    controller.define_singleton_method(:request) { nil }
    controller.define_singleton_method(:performed?) { false }

    line_items = controller.send(:build_line_items, cart)
    metadata = line_items.first[:price_data][:product_data][:metadata]

    assert_not_nil metadata[:product_id]
    assert_not_nil metadata[:product_stock_id]
    assert_not_nil metadata[:product_price]
    assert metadata.key?(:size)
  end
end
