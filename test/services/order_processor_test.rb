# frozen_string_literal: true

require 'test_helper'

class OrderProcessorTest < ActiveSupport::TestCase
  def setup
    @product = products(:product_one)
    @stock = stocks(:stock_one)
  end

  test 'initializes with a stripe session' do
    stripe_session = build_stripe_session
    processor = OrderProcessor.new(stripe_session)
    assert_instance_of OrderProcessor, processor
  end

  test 'process creates an order with correct attributes' do
    stripe_session = build_stripe_session
    processor = build_processor_with_mocks(stripe_session: stripe_session)
    order = processor.process

    assert_instance_of Order, order
    assert_equal 'customer@example.com', order.customer_email
    assert_equal 15_000, order.total
    assert_equal 'paid', order.payment_status
    assert_equal 'pi_test_123', order.payment_id
    assert_equal 'John Doe', order.name
    assert_equal 'John Billing', order.billing_name
    assert_equal false, order.fulfilled
  end

  test 'process creates order products for each line item' do
    stripe_session = build_stripe_session

    assert_difference 'OrderProduct.count', 1 do
      processor = build_processor_with_mocks(stripe_session: stripe_session)
      processor.process
    end
  end

  test 'process decrements product stock level when no size variant' do
    stripe_session = build_stripe_session
    original_stock = @product.stock_level

    processor = build_processor_with_mocks(stripe_session: stripe_session, with_size: false)
    processor.process

    @product.reload
    assert_equal original_stock - 2, @product.stock_level
  end

  test 'process decrements stock level when size variant exists' do
    stripe_session = build_stripe_session
    original_stock = @stock.stock_level

    processor = build_processor_with_mocks(stripe_session: stripe_session, with_size: true)
    processor.process

    @stock.reload
    assert_equal original_stock - 2, @stock.stock_level
  end

  test 'process completes successfully and creates order' do
    stripe_session = build_stripe_session

    processor = build_processor_with_mocks(stripe_session: stripe_session)
    order = processor.process

    assert order.persisted?
    assert_equal 'customer@example.com', order.customer_email
  end

  test 'process raises ProcessingError on failure' do
    stripe_session = build_stripe_session
    processor = OrderProcessor.new(stripe_session)

    error = assert_raises OrderProcessor::ProcessingError do
      processor.process
    end

    assert_match(/Failed to process order/, error.message)
  end

  test 'process handles shipping address from collected_information' do
    stripe_session = build_stripe_session
    processor = build_processor_with_mocks(stripe_session: stripe_session)
    order = processor.process

    assert_includes order.address, '123 Shipping St'
    assert_includes order.address, 'London'
  end

  test 'process handles missing collected_information gracefully' do
    stripe_session = build_stripe_session(with_collected_information: false)
    processor = build_processor_with_mocks(stripe_session: stripe_session)
    order = processor.process

    assert_equal 'Address not found.', order.address
    assert_equal 'John Billing', order.name
  end

  test 'process retrieves shipping description from Stripe' do
    stripe_session = build_stripe_session
    processor = build_processor_with_mocks(stripe_session: stripe_session)
    order = processor.process

    assert_equal 'Standard Delivery', order.shipping_description
  end

  test 'process uses Collection when no shipping_id' do
    stripe_session = build_stripe_session(with_shipping_id: false)
    processor = build_processor_with_mocks(stripe_session: stripe_session, with_shipping_id: false)
    order = processor.process

    assert_equal 'Collection', order.shipping_description
  end

  test 'process formats billing address correctly' do
    stripe_session = build_stripe_session
    processor = build_processor_with_mocks(stripe_session: stripe_session)
    order = processor.process

    assert_includes order.billing_address, '456 Billing Ave'
    assert_includes order.billing_address, 'Manchester'
  end

  test 'order product has correct price from metadata' do
    stripe_session = build_stripe_session
    processor = build_processor_with_mocks(stripe_session: stripe_session, with_size: false)
    processor.process

    order_product = OrderProduct.last
    assert_equal 1500, order_product.price
  end

  test 'order product has correct size when variant exists' do
    stripe_session = build_stripe_session
    processor = build_processor_with_mocks(stripe_session: stripe_session, with_size: true)
    processor.process

    order_product = OrderProduct.last
    assert_equal '1m x 10m Roll', order_product.size
  end

  private

  def build_stripe_session(with_collected_information: true, with_shipping_id: true)
    MockStripeSession.new(
      id: 'cs_test_123',
      with_collected_information: with_collected_information,
      with_shipping_id: with_shipping_id
    )
  end

  def build_processor_with_mocks(stripe_session:, with_size: false, with_shipping_id: true)
    MockableOrderProcessor.new(
      stripe_session,
      product: @product,
      stock: @stock,
      with_size: with_size,
      with_shipping_id: with_shipping_id
    )
  end

  class MockStripeSession
    attr_reader :id

    def initialize(id:, with_collected_information: true, with_shipping_id: true)
      @id = id
      @with_collected_information = with_collected_information
      @with_shipping_id = with_shipping_id
    end

    def [](key)
      session_data[key]
    end

    def dig(*keys)
      result = session_data
      keys.each do |key|
        return nil if result.nil?

        result = result.is_a?(Hash) ? result[key] : nil
      end
      result
    end

    private

    def session_data
      {
        'customer_details' => {
          'email' => 'customer@example.com',
          'phone' => '01234567890',
          'name' => 'John Billing',
          'address' => {
            'line1' => '456 Billing Ave',
            'line2' => 'Suite 100',
            'city' => 'Manchester',
            'state' => 'Greater Manchester',
            'postal_code' => 'M1 1AA',
            'country' => 'GB'
          }
        },
        'amount_total' => 15_000,
        'payment_status' => 'paid',
        'payment_intent' => 'pi_test_123',
        'shipping_cost' => if @with_shipping_id
                             {
                               'amount_total' => 500,
                               'shipping_rate' => 'shr_test_123'
                             }
                           else
                             {
                               'amount_total' => 0,
                               'shipping_rate' => nil
                             }
                           end,
        'collected_information' => if @with_collected_information
                                     {
                                       'shipping_details' => {
                                         'name' => 'John Doe',
                                         'address' => {
                                           'line1' => '123 Shipping St',
                                           'line2' => 'Apt 4B',
                                           'city' => 'London',
                                           'state' => 'Greater London',
                                           'postal_code' => 'SW1A 1AA',
                                           'country' => 'GB'
                                         }
                                       }
                                     }
                                   end
      }
    end
  end

  class MockableOrderProcessor < OrderProcessor
    def initialize(stripe_session, product:, stock:, with_size: false, with_shipping_id: true)
      super(stripe_session)
      @mock_product = product
      @mock_stock = stock
      @with_size = with_size
      @with_shipping_id = with_shipping_id
    end

    private

    def full_session
      @full_session ||= MockFullSession.new(line_items: mock_line_items)
    end

    def mock_line_items
      {
        'data' => [
          {
            'quantity' => 2,
            'price' => { 'product' => 'prod_test_123' }
          }
        ]
      }
    end

    def retrieve_stripe_product(_item)
      { 'metadata' => product_metadata }
    end

    def product_metadata
      if @with_size
        {
          'product_id' => @mock_product.id.to_s,
          'size' => '1m x 10m Roll',
          'product_stock_id' => @mock_stock.id.to_s,
          'product_price' => '14000'
        }
      else
        {
          'product_id' => @mock_product.id.to_s,
          'size' => '',
          'product_stock_id' => '',
          'product_price' => '1500'
        }
      end
    end

    def shipping_description
      return 'Collection' unless @with_shipping_id

      'Standard Delivery'
    end

    class MockFullSession
      attr_reader :line_items

      def initialize(line_items:)
        @line_items = line_items
      end
    end
  end
end
