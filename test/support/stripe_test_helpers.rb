# frozen_string_literal: true

# Stripe webhook testing helpers for integration tests.
#
# Usage in tests:
#
#   class WebhookTest < ActionDispatch::IntegrationTest
#     include StripeTestHelpers
#
#     test 'should process checkout.session.completed webhook' do
#       data = build_checkout_session_data(email: 'customer@example.com')
#       post_stripe_webhook('checkout.session.completed', data)
#       assert_response :success
#     end
#   end
#
# Helper Methods:
# - load_stripe_fixture(name) - Load JSON fixtures from test/fixtures/stripe/
# - generate_stripe_signature(payload) - Generate valid Stripe webhook signature
# - post_stripe_webhook(event_type, data) - Post webhook with valid signature
# - build_checkout_session_data(options) - Build checkout.session.completed data
#
module StripeTestHelpers
  # Load a JSON fixture from test/fixtures/stripe/
  #
  # @param name [String] fixture filename without .json extension
  # @return [Hash] parsed JSON fixture data
  #
  # Example:
  #   fixture = load_stripe_fixture('checkout_session_completed')
  #
  def load_stripe_fixture(name)
    fixture_path = stripe_fixtures_path.join("#{name}.json")
    raise "Stripe fixture not found: #{fixture_path}" unless File.exist?(fixture_path)

    JSON.parse(File.read(fixture_path))
  end

  # Generate a valid Stripe webhook signature for testing.
  # Uses test webhook secret if available, otherwise generates a test secret.
  #
  # @param payload [String] JSON payload string
  # @param timestamp [Integer] Unix timestamp (default: current time)
  # @return [String] Stripe signature header value
  #
  # Example:
  #   signature = generate_stripe_signature(payload.to_json)
  #
  def generate_stripe_signature(payload, timestamp: nil)
    timestamp ||= Time.current.to_i
    webhook_secret = stripe_test_webhook_secret

    signed_payload = "#{timestamp}.#{payload}"
    signature = OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, signed_payload)

    "t=#{timestamp},v1=#{signature}"
  end

  # Post a Stripe webhook event to the webhook endpoint with valid signature.
  #
  # @param event_type [String] Stripe event type (e.g., 'checkout.session.completed')
  # @param data [Hash] event data object
  # @param endpoint [String] webhook endpoint path (default: '/webhooks')
  # @return [void]
  #
  # Example:
  #   post_stripe_webhook('checkout.session.completed', session_data)
  #
  def post_stripe_webhook(event_type, data, endpoint: '/webhooks')
    payload = build_stripe_event_payload(event_type, data)
    json_payload = payload.to_json
    signature = generate_stripe_signature(json_payload)

    post endpoint,
         params: json_payload,
         headers: {
           'Content-Type' => 'application/json',
           'Stripe-Signature' => signature
         }
  end

  # Build a complete checkout.session.completed event data object.
  # Provides sensible defaults that can be overridden.
  #
  # @param options [Hash] override default values
  # @option options [String] :email customer email
  # @option options [String] :name customer name
  # @option options [Integer] :amount_total total amount in pence
  # @option options [String] :payment_status payment status
  # @option options [String] :session_id Stripe session ID
  # @option options [String] :payment_intent_id Stripe payment intent ID
  # @option options [Integer] :shipping_cost shipping cost in pence (default: 500)
  # @return [Hash] checkout session data
  #
  # Example:
  #   data = build_checkout_session_data(
  #     email: 'test@example.com',
  #     amount_total: 5000,
  #     shipping_cost: 750
  #   )
  #
  def build_checkout_session_data(options = {})
    defaults = {
      id: options[:session_id] || "cs_test_#{SecureRandom.hex(12)}",
      object: 'checkout.session',
      amount_total: options[:amount_total] || 15_000,
      currency: 'gbp',
      customer_details: {
        email: options[:email] || 'test@example.com',
        name: options[:name] || 'Test Customer',
        phone: options[:phone] || '01234567890',
        address: {
          line1: options.dig(:billing_address, :line1) || '123 Billing St',
          line2: options.dig(:billing_address, :line2) || 'Suite 100',
          city: options.dig(:billing_address, :city) || 'London',
          state: options.dig(:billing_address, :state) || '',
          postal_code: options.dig(:billing_address, :postal_code) || 'SW1A 1AA',
          country: options.dig(:billing_address, :country) || 'GB'
        }
      },
      collected_information: {
        shipping_details: {
          name: options[:shipping_name] || options[:name] || 'Test Customer',
          address: {
            line1: options.dig(:shipping_address, :line1) || '456 Shipping Ave',
            line2: options.dig(:shipping_address, :line2) || '',
            city: options.dig(:shipping_address, :city) || 'Manchester',
            state: options.dig(:shipping_address, :state) || '',
            postal_code: options.dig(:shipping_address, :postal_code) || 'M1 1AA',
            country: options.dig(:shipping_address, :country) || 'GB'
          }
        }
      },
      payment_status: options[:payment_status] || 'paid',
      payment_intent: options[:payment_intent_id] || "pi_test_#{SecureRandom.hex(12)}",
      shipping_cost: {
        amount_total: options[:shipping_cost] || 500,
        shipping_rate: options[:shipping_rate_id] || "shr_test_#{SecureRandom.hex(12)}"
      },
      metadata: options[:metadata] || {}
    }

    defaults.deep_merge(options.slice(:customer_details, :collected_information, :metadata))
  end

  # Build line items for a checkout session with product metadata.
  #
  # @param items [Array<Hash>] array of item hashes with product info
  # @option item [Integer] :product_id product ID from database
  # @option item [String] :size product size variant (optional)
  # @option item [Integer] :stock_id stock ID for size variants
  # @option item [Integer] :price price in pence
  # @option item [Integer] :quantity item quantity
  # @return [Array<Hash>] formatted line items for Stripe response
  #
  # Example:
  #   line_items = build_line_items([
  #     { product_id: 1, price: 1500, quantity: 2 }
  #   ])
  #
  def build_stripe_line_items(items)
    items.map do |item|
      {
        id: "li_test_#{SecureRandom.hex(8)}",
        object: 'item',
        quantity: item[:quantity] || 1,
        price: {
          id: "price_test_#{SecureRandom.hex(8)}",
          product: "prod_test_#{SecureRandom.hex(8)}"
        }
      }
    end
  end

  # Build a Stripe product object with metadata for webhook processing.
  #
  # @param product_id [Integer] database product ID
  # @param size [String] product size variant (optional)
  # @param stock_id [Integer] stock ID for size variants (optional)
  # @param price [Integer] product price in pence
  # @return [Hash] Stripe product object with metadata
  #
  # Example:
  #   product = build_stripe_product(product_id: 1, price: 1500)
  #
  def build_stripe_product(product_id:, price:, size: nil, stock_id: nil)
    {
      id: "prod_test_#{SecureRandom.hex(8)}",
      object: 'product',
      name: "Test Product #{product_id}",
      metadata: {
        product_id: product_id.to_s,
        size: size.to_s,
        product_stock_id: (stock_id || product_id).to_s,
        product_price: price.to_s
      }
    }
  end

  private

  # Build a complete Stripe event payload.
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

  # Get the Stripe webhook secret for testing.
  # Uses environment variable or returns a default test secret.
  #
  # @return [String] webhook secret
  #
  def stripe_test_webhook_secret
    ENV['STRIPE_WEBHOOK_KEY'] || 'whsec_test_webhook_secret_for_testing'
  end

  # Get the path to Stripe fixtures directory.
  #
  # @return [Pathname] path to test/fixtures/stripe/
  #
  def stripe_fixtures_path
    Rails.root.join('test/fixtures/stripe')
  end
end
