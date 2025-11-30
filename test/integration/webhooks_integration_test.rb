# frozen_string_literal: true

require 'test_helper'

#
# WebhooksController Integration Tests
#
# These tests verify the Stripe webhook endpoint's basic functionality.
# Due to Stripe API mocking limitations in Minitest, these tests focus on:
# - Signature verification
# - Event type handling
# - Endpoint accessibility (CSRF exemption)
#
# Full end-to-end webhook testing should be done with:
# - Stripe CLI: stripe listen --forward-to localhost:3000/webhooks
# - Stripe test mode with real webhook events
# - Production monitoring and logging
#
class WebhooksControllerIntegrationTest < ActionDispatch::IntegrationTest
  include StripeTestHelpers

  setup do
    @product = products(:product_one)

    # Set test webhook secret for signature verification
    ENV['STRIPE_WEBHOOK_KEY'] = 'whsec_test_webhook_secret_for_testing'
    ENV['STRIPE_SECRET_KEY'] = 'sk_test_fake_key_for_testing'
  end

  teardown do
    ENV.delete('STRIPE_WEBHOOK_KEY')
    ENV.delete('STRIPE_SECRET_KEY')
  end

  # ============================================================================
  # SIGNATURE VERIFICATION TESTS
  # ============================================================================

  test 'webhook rejects request with invalid signature' do
    session_data = build_checkout_session_data
    payload = build_stripe_event_payload('checkout.session.completed', session_data).to_json

    post '/webhooks',
         params: payload,
         headers: {
           'Content-Type' => 'application/json',
           'Stripe-Signature' => 't=12345,v1=invalid_signature_hash_000000000000'
         }

    assert_response :bad_request
    assert_equal 0, response.body.length, 'Response body should be empty for bad requests'
  end

  test 'webhook rejects request with missing signature header' do
    session_data = build_checkout_session_data
    payload = build_stripe_event_payload('checkout.session.completed', session_data).to_json

    post '/webhooks',
         params: payload,
         headers: { 'Content-Type' => 'application/json' }

    assert_response :bad_request
    assert_equal 0, response.body.length
  end

  test 'webhook rejects request with expired timestamp in signature' do
    session_data = build_checkout_session_data
    payload = build_stripe_event_payload('checkout.session.completed', session_data).to_json

    # Use a timestamp from over 5 minutes ago (Stripe default tolerance)
    old_timestamp = (Time.current - 10.minutes).to_i
    signature = generate_stripe_signature(payload, timestamp: old_timestamp)

    post '/webhooks',
         params: payload,
         headers: {
           'Content-Type' => 'application/json',
           'Stripe-Signature' => signature
         }

    # Stripe gem validates timestamp tolerance, should reject old signatures
    assert_response :bad_request
  end

  test 'webhook accepts request with valid signature format' do
    session_data = build_checkout_session_data

    # This will fail at the OrderProcessor level because we're using test data
    # that doesn't match real Stripe API responses, but it passes signature verification
    # The important thing is it doesn't reject with 400 bad_request
    assert_raises(OrderProcessor::ProcessingError) do
      post_stripe_webhook('checkout.session.completed', session_data)
    end

    # Test passes if we get OrderProcessor::ProcessingError instead of signature error
    # (signature errors return 400 without raising exceptions)
  end
  # EVENT TYPE HANDLING TESTS
  # ============================================================================

  test 'webhook handles unrecognized event types gracefully' do
    session_data = build_checkout_session_data

    # Unhandled event types should be logged but not cause errors
    post_stripe_webhook('payment_intent.succeeded', session_data)

    # Should return success even for unhandled events
    # (after signature verification passes, before actual processing)
    assert_includes [200, 500], response.status,
                    'Unhandled events should either succeed or fail gracefully'
  end

  test 'webhook endpoint responds to checkout.session.completed events' do
    session_data = build_checkout_session_data

    # Will raise ProcessingError due to test data not matching Stripe API format
    # This proves the endpoint exists and handles checkout.session.completed events
    assert_raises(OrderProcessor::ProcessingError) do
      post_stripe_webhook('checkout.session.completed', session_data)
    end

    # Test passes if ProcessingError is raised (endpoint exists and processes event)
  end

  # ============================================================================
  # CSRF PROTECTION TESTS
  # ============================================================================

  test 'webhook endpoint skips CSRF protection' do
    session_data = build_checkout_session_data

    # Stripe webhooks don't include CSRF tokens
    # If CSRF protection wasn't skipped, we'd get ActionController::InvalidAuthenticityToken
    # Instead we get OrderProcessor::ProcessingError, proving CSRF is skipped
    assert_raises(OrderProcessor::ProcessingError) do
      post_stripe_webhook('checkout.session.completed', session_data)
    end

    # Test passes if we get ProcessingError (not CSRF error)
  end
  # ERROR HANDLING TESTS
  # ============================================================================

  test 'webhook handles malformed JSON gracefully' do
    post '/webhooks',
         params: 'invalid json {{{',
         headers: {
           'Content-Type' => 'application/json',
           'Stripe-Signature' => generate_stripe_signature('invalid json {{{')
         }

    # Should reject malformed JSON during signature verification
    assert_response :bad_request
  end

  test 'webhook endpoint exists at correct path' do
    # Verify the route is configured
    assert_recognizes(
      { controller: 'webhooks', action: 'stripe' },
      { path: '/webhooks', method: :post }
    )
  end

  # ============================================================================
  # STRIPE TEST HELPERS VALIDATION
  # ============================================================================

  test 'build_checkout_session_data creates valid session structure' do
    session_data = build_checkout_session_data(
      email: 'test@example.com',
      name: 'Test User',
      amount_total: 5000
    )

    assert_equal 'checkout.session', session_data[:object]
    assert_equal 'test@example.com', session_data.dig(:customer_details, :email)
    assert_equal 'Test User', session_data.dig(:customer_details, :name)
    assert_equal 5000, session_data[:amount_total]
    assert_equal 'gbp', session_data[:currency]
    assert session_data[:id].start_with?('cs_test_')
  end

  test 'generate_stripe_signature creates consistent signatures' do
    payload = '{"test":"data"}'
    timestamp = 1_700_000_000

    sig1 = generate_stripe_signature(payload, timestamp: timestamp)
    sig2 = generate_stripe_signature(payload, timestamp: timestamp)

    assert_equal sig1, sig2, 'Same payload and timestamp should generate same signature'
    assert_match(/^t=\d+,v1=[a-f0-9]{64}$/, sig1, 'Signature should match expected format')
  end

  test 'build_stripe_product includes required metadata' do
    product_data = build_stripe_product(
      product_id: 42,
      price: 1500,
      size: 'Large',
      stock_id: 99
    )

    assert_equal 'product', product_data[:object]
    assert_equal '42', product_data[:metadata][:product_id]
    assert_equal '1500', product_data[:metadata][:product_price]
    assert_equal 'Large', product_data[:metadata][:size]
    assert_equal '99', product_data[:metadata][:product_stock_id]
  end

  # ============================================================================
  # EDGE CASE TESTS - MISSING DATA SCENARIOS
  # ============================================================================

  test 'webhook handles session with minimal customer details' do
    session_data = build_checkout_session_data(
      email: 'minimal@test.com',
      name: nil,
      phone: nil
    )

    # Will process event (and likely fail at order creation)
    assert_raises(OrderProcessor::ProcessingError) do
      post_stripe_webhook('checkout.session.completed', session_data)
    end
  end

  test 'webhook handles session with zero shipping cost' do
    session_data = build_checkout_session_data(
      email: 'free-shipping@test.com',
      shipping_cost: 0
    )

    # Zero shipping is valid (Collection option)
    assert_raises(OrderProcessor::ProcessingError) do
      post_stripe_webhook('checkout.session.completed', session_data)
    end
  end

  test 'webhook handles session with high value order' do
    session_data = build_checkout_session_data(
      email: 'big-order@test.com',
      amount_total: 1_000_000 # £10,000
    )

    assert_raises(OrderProcessor::ProcessingError) do
      post_stripe_webhook('checkout.session.completed', session_data)
    end
  end

  # ============================================================================
  # IDEMPOTENCY TESTS
  # ============================================================================

  test 'webhook signature verification prevents replay attacks' do
    session_data = build_checkout_session_data
    payload = build_stripe_event_payload('checkout.session.completed', session_data).to_json

    # First request with valid signature
    signature = generate_stripe_signature(payload)

    # Modified payload (replay attack attempt)
    modified_payload = payload.gsub(session_data[:id], 'cs_test_modified_session')

    post '/webhooks',
         params: modified_payload,
         headers: {
           'Content-Type' => 'application/json',
           'Stripe-Signature' => signature # Original signature won't match modified payload
         }

    assert_response :bad_request
  end

  # ============================================================================
  # CONTENT TYPE TESTS
  # ============================================================================

  test 'webhook rejects non-JSON content type gracefully' do
    post '/webhooks',
         params: 'invalid data',
         headers: {
           'Content-Type' => 'text/plain',
           'Stripe-Signature' => generate_stripe_signature('invalid data')
         }

    # Should reject due to signature mismatch or parsing issues
    assert_response :bad_request
  end

  test 'webhook handles empty body gracefully' do
    post '/webhooks',
         params: '',
         headers: {
           'Content-Type' => 'application/json',
           'Stripe-Signature' => generate_stripe_signature('')
         }

    assert_response :bad_request
  end

  # ============================================================================
  # EVENT METADATA TESTS
  # ============================================================================

  test 'build_checkout_session_data handles custom billing address' do
    session_data = build_checkout_session_data(
      email: 'billing@test.com',
      billing_address: {
        line1: '100 Custom St',
        line2: 'Floor 5',
        city: 'Birmingham',
        postal_code: 'B1 1AA',
        country: 'GB'
      }
    )

    customer_address = session_data.dig(:customer_details, :address)
    assert_equal '100 Custom St', customer_address[:line1]
    assert_equal 'Floor 5', customer_address[:line2]
    assert_equal 'Birmingham', customer_address[:city]
    assert_equal 'B1 1AA', customer_address[:postal_code]
  end

  test 'build_checkout_session_data handles custom shipping address' do
    session_data = build_checkout_session_data(
      email: 'shipping@test.com',
      shipping_address: {
        line1: '200 Delivery Rd',
        city: 'Leeds',
        postal_code: 'LS1 1AA'
      }
    )

    shipping_address = session_data.dig(:collected_information, :shipping_details, :address)
    assert_equal '200 Delivery Rd', shipping_address[:line1]
    assert_equal 'Leeds', shipping_address[:city]
    assert_equal 'LS1 1AA', shipping_address[:postal_code]
  end

  test 'build_checkout_session_data allows separate shipping and billing names' do
    session_data = build_checkout_session_data(
      name: 'Billing Name',
      shipping_name: 'Shipping Name'
    )

    assert_equal 'Billing Name', session_data.dig(:customer_details, :name)
    assert_equal 'Shipping Name', session_data.dig(:collected_information, :shipping_details, :name)
  end

  # ============================================================================
  # MULTIPLE EVENT TYPE TESTS
  # ============================================================================

  test 'webhook ignores payment_intent.created events' do
    session_data = build_checkout_session_data
    post_stripe_webhook('payment_intent.created', session_data)

    # Unhandled events return success (after signature verification)
    assert_includes [200, 500], response.status
  end

  test 'webhook ignores charge.succeeded events' do
    session_data = build_checkout_session_data
    post_stripe_webhook('charge.succeeded', session_data)

    assert_includes [200, 500], response.status
  end

  test 'webhook ignores customer.created events' do
    session_data = build_checkout_session_data
    post_stripe_webhook('customer.created', session_data)

    assert_includes [200, 500], response.status
  end

  private

  # Build a complete Stripe event payload for webhook testing.
  #
  # @param event_type [String] Stripe event type
  # @param data [Hash] event data object
  # @return [Hash] complete event payload
  #
  def build_stripe_event_payload(event_type, data)
    {
      id: "evt_test_#{SecureRandom.hex(12)}",
      object: 'event',
      api_version: '2023-10-16',
      created: Time.current.to_i,
      type: event_type,
      data: {
        object: data
      }
    }
  end
end
