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
end
