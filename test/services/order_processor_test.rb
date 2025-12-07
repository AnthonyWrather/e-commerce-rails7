# frozen_string_literal: true

require 'test_helper'

class OrderProcessorTest < ActiveSupport::TestCase
  test 'OrderProcessor class exists' do
    assert OrderProcessor
  end

  test 'OrderProcessor defines ProcessingError exception' do
    assert OrderProcessor::ProcessingError < StandardError
  end

  test 'find_user_by_email returns user when email matches' do
    user = users(:user_one)
    mock_session = build_stripe_session(email: user.email)
    processor = OrderProcessor.new(mock_session)

    found_user = processor.send(:find_user_by_email)

    assert_equal user, found_user
  end

  test 'find_user_by_email returns nil when no user matches' do
    mock_session = build_stripe_session(email: 'nonexistent@example.com')
    processor = OrderProcessor.new(mock_session)

    found_user = processor.send(:find_user_by_email)

    assert_nil found_user
  end

  test 'find_user_by_email handles guest orders without user' do
    mock_session = build_stripe_session(email: 'guest@example.com')
    processor = OrderProcessor.new(mock_session)

    found_user = processor.send(:find_user_by_email)

    assert_nil found_user
  end

  test 'customer_email extracts email from Stripe session' do
    mock_session = build_stripe_session(email: 'test@example.com')
    processor = OrderProcessor.new(mock_session)

    email = processor.send(:customer_email)

    assert_equal 'test@example.com', email
  end

  test 'phone extracts phone from Stripe session' do
    mock_session = build_stripe_session(phone: '01234567890')
    processor = OrderProcessor.new(mock_session)

    phone = processor.send(:phone)

    assert_equal '01234567890', phone
  end

  test 'billing_name extracts name from Stripe session' do
    mock_session = build_stripe_session(name: 'John Doe')
    processor = OrderProcessor.new(mock_session)

    name = processor.send(:billing_name)

    assert_equal 'John Doe', name
  end

  test 'billing_address formats address correctly using bracket notation' do
    mock_session = build_stripe_session(
      billing_address: {
        line1: '123 Test St',
        line2: 'Apt 4',
        city: 'London',
        state: 'Greater London',
        postal_code: 'SW1A 1AA',
        country: 'GB'
      }
    )
    processor = OrderProcessor.new(mock_session)

    address = processor.send(:billing_address)

    assert_equal '123 Test St, Apt 4, London, Greater London, SW1A 1AA, GB', address
  end

  test 'billing_address returns empty string when address missing' do
    mock_session = build_stripe_session_without_billing_address
    processor = OrderProcessor.new(mock_session)

    address = processor.send(:billing_address)

    assert_equal '', address
  end

  test 'shipping_address formats address correctly using bracket notation' do
    mock_session = build_stripe_session(
      shipping_address: {
        line1: '456 Shipping Ave',
        line2: '',
        city: 'Manchester',
        state: '',
        postal_code: 'M1 1AA',
        country: 'GB'
      }
    )
    processor = OrderProcessor.new(mock_session)

    address = processor.send(:shipping_address)

    assert_equal '456 Shipping Ave, Manchester, M1 1AA, GB', address
  end

  test 'shipping_address returns default when collected_information missing' do
    mock_session = build_stripe_session_without_shipping
    processor = OrderProcessor.new(mock_session)

    address = processor.send(:shipping_address)

    assert_equal 'Address not found.', address
  end

  test 'shipping_address returns default when shipping_details missing' do
    mock_session = build_stripe_session_without_shipping_details
    processor = OrderProcessor.new(mock_session)

    address = processor.send(:shipping_address)

    assert_equal 'Address not found.', address
  end

  test 'shipping_name extracts shipping name using bracket notation' do
    mock_session = build_stripe_session(shipping_name: 'Jane Smith')
    processor = OrderProcessor.new(mock_session)

    name = processor.send(:shipping_name)

    assert_equal 'Jane Smith', name
  end

  test 'shipping_name falls back to billing_name when shipping name missing' do
    mock_session = build_stripe_session_without_shipping_name
    processor = OrderProcessor.new(mock_session)

    name = processor.send(:shipping_name)

    assert_equal 'Test Customer', name
  end

  test 'shipping_cost extracts cost using bracket notation' do
    mock_session = build_stripe_session(shipping_cost: 750)
    processor = OrderProcessor.new(mock_session)

    cost = processor.send(:shipping_cost)

    assert_equal 750, cost
  end

  test 'shipping_cost returns nil when missing' do
    mock_session = build_stripe_session_without_shipping_cost
    processor = OrderProcessor.new(mock_session)

    cost = processor.send(:shipping_cost)

    assert_nil cost
  end

  test 'shipping_id extracts shipping rate ID using bracket notation' do
    mock_session = build_stripe_session(shipping_rate_id: 'shr_test_123')
    processor = OrderProcessor.new(mock_session)

    shipping_id = processor.send(:shipping_id)

    assert_equal 'shr_test_123', shipping_id
  end

  test 'shipping_id returns nil when missing' do
    mock_session = build_stripe_session_without_shipping_cost
    processor = OrderProcessor.new(mock_session)

    shipping_id = processor.send(:shipping_id)

    assert_nil shipping_id
  end

  test 'format_address handles nil line2' do
    processor = OrderProcessor.new(build_stripe_session)
    address = {
      'line1' => '123 Test St',
      'line2' => nil,
      'city' => 'London',
      'state' => '',
      'postal_code' => 'SW1A 1AA',
      'country' => 'GB'
    }

    formatted = processor.send(:format_address, address)

    assert_equal '123 Test St, London, SW1A 1AA, GB', formatted
  end

  # NOTE: OrderProcessor is a service class that processes Stripe checkout sessions.
  # It requires complex Stripe API mocking for comprehensive unit tests.
  #
  # The service is currently tested through:
  # 1. Integration with WebhooksController (webhook receives real Stripe events in test mode)
  # 2. Manual end-to-end testing with Stripe test cards
  # 3. Production monitoring and error tracking
  #
  # To add comprehensive unit tests in the future, you would need to:
  # - Create mock Stripe::Checkout::Session objects with all required nested data
  # - Mock Stripe::Checkout::Session.retrieve (with line_items expansion)
  # - Mock Stripe::Product.retrieve for each line item
  # - Mock Stripe::ShippingRate.retrieve for shipping details
  #
  # Test coverage areas to implement:
  # ✓ Order creation with customer details (email, name, phone, addresses)
  # ✓ Order totals and payment status
  # ✓ OrderProduct creation from line items
  # ✓ Stock decrementing (both Product and Stock models)
  # ✓ Email confirmation sending
  # ✓ Transaction rollback on errors
  # ✓ Edge cases (missing addresses, collection shipping, multiple items)
  # ✓ User assignment via email lookup (Story 4.2)

  private

  # Build a mock Stripe::StripeObject with the structure expected by OrderProcessor
  def build_stripe_session(options = {})
    Stripe::StripeObject.construct_from({
      'id' => options[:session_id] || "cs_test_#{SecureRandom.hex(12)}",
      'object' => 'checkout.session',
      'amount_total' => options[:amount_total] || 15_000,
      'currency' => 'gbp',
      'customer_details' => {
        'email' => options[:email] || 'test@example.com',
        'name' => options[:name] || 'Test Customer',
        'phone' => options[:phone] || '01234567890',
        'address' => {
          'line1' => options.dig(:billing_address, :line1) || '123 Billing St',
          'line2' => options.dig(:billing_address, :line2) || 'Suite 100',
          'city' => options.dig(:billing_address, :city) || 'London',
          'state' => options.dig(:billing_address, :state) || '',
          'postal_code' => options.dig(:billing_address, :postal_code) || 'SW1A 1AA',
          'country' => options.dig(:billing_address, :country) || 'GB'
        }
      },
      'collected_information' => {
        'shipping_details' => {
          'name' => options[:shipping_name] || options[:name] || 'Test Customer',
          'address' => {
            'line1' => options.dig(:shipping_address, :line1) || '456 Shipping Ave',
            'line2' => options.dig(:shipping_address, :line2) || '',
            'city' => options.dig(:shipping_address, :city) || 'Manchester',
            'state' => options.dig(:shipping_address, :state) || '',
            'postal_code' => options.dig(:shipping_address, :postal_code) || 'M1 1AA',
            'country' => options.dig(:shipping_address, :country) || 'GB'
          }
        }
      },
      'payment_status' => options[:payment_status] || 'paid',
      'payment_intent' => options[:payment_intent_id] || "pi_test_#{SecureRandom.hex(12)}",
      'shipping_cost' => {
        'amount_total' => options[:shipping_cost] || 500,
        'shipping_rate' => options[:shipping_rate_id] || "shr_test_#{SecureRandom.hex(12)}"
      },
      'metadata' => options[:metadata] || {}
    })
  end

  def build_stripe_session_without_billing_address
    Stripe::StripeObject.construct_from({
      'customer_details' => {
        'email' => 'test@example.com',
        'name' => 'Test Customer',
        'phone' => '01234567890'
      },
      'collected_information' => {
        'shipping_details' => {
          'name' => 'Test Customer',
          'address' => {
            'line1' => '456 Shipping Ave',
            'city' => 'Manchester',
            'postal_code' => 'M1 1AA',
            'country' => 'GB'
          }
        }
      },
      'payment_status' => 'paid',
      'payment_intent' => 'pi_test_123'
    })
  end

  def build_stripe_session_without_shipping
    Stripe::StripeObject.construct_from({
      'customer_details' => {
        'email' => 'test@example.com',
        'name' => 'Test Customer',
        'phone' => '01234567890',
        'address' => {
          'line1' => '123 Test St',
          'city' => 'London',
          'postal_code' => 'SW1A 1AA',
          'country' => 'GB'
        }
      },
      'payment_status' => 'paid',
      'payment_intent' => 'pi_test_123'
    })
  end

  def build_stripe_session_without_shipping_details
    Stripe::StripeObject.construct_from({
      'customer_details' => {
        'email' => 'test@example.com',
        'name' => 'Test Customer',
        'phone' => '01234567890',
        'address' => {
          'line1' => '123 Test St',
          'city' => 'London',
          'postal_code' => 'SW1A 1AA',
          'country' => 'GB'
        }
      },
      'collected_information' => {},
      'payment_status' => 'paid',
      'payment_intent' => 'pi_test_123'
    })
  end

  def build_stripe_session_without_shipping_name
    Stripe::StripeObject.construct_from({
      'customer_details' => {
        'email' => 'test@example.com',
        'name' => 'Test Customer',
        'phone' => '01234567890',
        'address' => {
          'line1' => '123 Test St',
          'city' => 'London',
          'postal_code' => 'SW1A 1AA',
          'country' => 'GB'
        }
      },
      'collected_information' => {
        'shipping_details' => {
          'address' => {
            'line1' => '456 Shipping Ave',
            'city' => 'Manchester',
            'postal_code' => 'M1 1AA',
            'country' => 'GB'
          }
        }
      },
      'payment_status' => 'paid',
      'payment_intent' => 'pi_test_123'
    })
  end

  def build_stripe_session_without_shipping_cost
    Stripe::StripeObject.construct_from({
      'customer_details' => {
        'email' => 'test@example.com',
        'name' => 'Test Customer',
        'phone' => '01234567890',
        'address' => {
          'line1' => '123 Test St',
          'city' => 'London',
          'postal_code' => 'SW1A 1AA',
          'country' => 'GB'
        }
      },
      'collected_information' => {
        'shipping_details' => {
          'name' => 'Test Customer',
          'address' => {
            'line1' => '456 Shipping Ave',
            'city' => 'Manchester',
            'postal_code' => 'M1 1AA',
            'country' => 'GB'
          }
        }
      },
      'payment_status' => 'paid',
      'payment_intent' => 'pi_test_123'
    })
  end
end
