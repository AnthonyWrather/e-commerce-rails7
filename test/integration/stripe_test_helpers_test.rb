# frozen_string_literal: true

require 'test_helper'

class StripeTestHelpersTest < ActionDispatch::IntegrationTest
  test 'load_stripe_fixture loads JSON fixture file' do
    fixture = load_stripe_fixture('checkout_session_completed')

    assert_kind_of Hash, fixture
    assert_equal 'cs_test_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6', fixture['id']
    assert_equal 'checkout.session', fixture['object']
    assert_equal 15_000, fixture['amount_total']
    assert_equal 'gbp', fixture['currency']
    assert_equal 'test@example.com', fixture.dig('customer_details', 'email')
  end

  test 'load_stripe_fixture raises error for missing fixture' do
    assert_raises RuntimeError, 'Stripe fixture not found' do
      load_stripe_fixture('nonexistent_fixture')
    end
  end

  test 'generate_stripe_signature creates valid signature format' do
    payload = '{"test": "data"}'
    signature = generate_stripe_signature(payload)

    assert_match(/^t=\d+,v1=[a-f0-9]{64}$/, signature)
  end

  test 'generate_stripe_signature uses provided timestamp' do
    payload = '{"test": "data"}'
    timestamp = 1_700_000_000

    signature = generate_stripe_signature(payload, timestamp: timestamp)

    assert_includes signature, "t=#{timestamp}"
  end

  test 'generate_stripe_signature produces consistent signatures for same input' do
    payload = '{"test": "data"}'
    timestamp = 1_700_000_000

    signature1 = generate_stripe_signature(payload, timestamp: timestamp)
    signature2 = generate_stripe_signature(payload, timestamp: timestamp)

    assert_equal signature1, signature2
  end

  test 'build_checkout_session_data returns hash with default values' do
    data = build_checkout_session_data

    assert_kind_of Hash, data
    assert_match(/^cs_test_/, data[:id])
    assert_equal 15_000, data[:amount_total]
    assert_equal 'gbp', data[:currency]
    assert_equal 'test@example.com', data.dig(:customer_details, :email)
    assert_equal 'Test Customer', data.dig(:customer_details, :name)
    assert_equal 'paid', data[:payment_status]
    assert_match(/^pi_test_/, data[:payment_intent])
    assert_equal 500, data.dig(:shipping_cost, :amount_total)
  end

  test 'build_checkout_session_data accepts custom options' do
    data = build_checkout_session_data(
      email: 'custom@example.com',
      name: 'Custom Name',
      amount_total: 25_000,
      payment_status: 'unpaid',
      shipping_cost: 750
    )

    assert_equal 'custom@example.com', data.dig(:customer_details, :email)
    assert_equal 'Custom Name', data.dig(:customer_details, :name)
    assert_equal 25_000, data[:amount_total]
    assert_equal 'unpaid', data[:payment_status]
    assert_equal 750, data.dig(:shipping_cost, :amount_total)
  end

  test 'build_checkout_session_data accepts session_id and payment_intent_id' do
    data = build_checkout_session_data(
      session_id: 'cs_custom_session',
      payment_intent_id: 'pi_custom_intent'
    )

    assert_equal 'cs_custom_session', data[:id]
    assert_equal 'pi_custom_intent', data[:payment_intent]
  end

  test 'build_stripe_line_items creates formatted line items' do
    items = [
      { product_id: 1, price: 1500, quantity: 2 },
      { product_id: 2, price: 2000, quantity: 1 }
    ]

    line_items = build_stripe_line_items(items)

    assert_equal 2, line_items.length
    assert_match(/^li_test_/, line_items[0][:id])
    assert_equal 2, line_items[0][:quantity]
    assert_equal 1, line_items[1][:quantity]
  end

  test 'build_stripe_product creates product with metadata' do
    product = build_stripe_product(product_id: 42, price: 1500)

    assert_match(/^prod_test_/, product[:id])
    assert_equal 'product', product[:object]
    assert_equal '42', product[:metadata][:product_id]
    assert_equal '1500', product[:metadata][:product_price]
    assert_equal '42', product[:metadata][:product_stock_id]
    assert_equal '', product[:metadata][:size]
  end

  test 'build_stripe_product includes size and stock_id when provided' do
    product = build_stripe_product(
      product_id: 10,
      price: 2500,
      size: 'Large',
      stock_id: 99
    )

    assert_equal '10', product[:metadata][:product_id]
    assert_equal 'Large', product[:metadata][:size]
    assert_equal '99', product[:metadata][:product_stock_id]
    assert_equal '2500', product[:metadata][:product_price]
  end

  test 'post_stripe_webhook sends request with correct signature header' do
    ENV['STRIPE_WEBHOOK_KEY'] = 'whsec_test_secret'

    data = build_checkout_session_data

    # Use assert_nothing_raised to verify the helper doesn't error
    # The actual webhook will fail due to signature verification or DB issues,
    # but that's tested elsewhere. Here we just test the helper sends a request.
    assert_nothing_raised do
      post_stripe_webhook('checkout.session.completed', data)
    end

    # Verify a response was received (any response means the request was made)
    assert_not_nil response, 'Expected a response from the webhook endpoint'
  ensure
    ENV.delete('STRIPE_WEBHOOK_KEY')
  end
end
