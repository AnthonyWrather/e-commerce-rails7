# frozen_string_literal: true

class OrderProcessor
  class ProcessingError < StandardError; end

  def initialize(stripe_session)
    @stripe_session = stripe_session
    @stripe_products = {}
  end

  def process
    ActiveRecord::Base.transaction do
      @order = create_order
      process_line_items
      send_confirmation_email
    end
    @order
  rescue StandardError => e
    Rails.logger.error("OrderProcessor failed: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))
    raise ProcessingError, "Failed to process order: #{e.message}"
  end

  private

  def create_order
    Order.create!(
      user: find_user_by_email,
      customer_email: customer_email, total: @stripe_session['amount_total'],
      address: shipping_address, fulfilled: false, name: shipping_name,
      phone: phone, billing_name: billing_name, billing_address: billing_address,
      payment_status: @stripe_session['payment_status'], payment_id: @stripe_session['payment_intent'],
      shipping_cost: shipping_cost, shipping_id: shipping_id, shipping_description: shipping_description
    )
  end

  def find_user_by_email
    User.find_by(email: customer_email)
  end

  def process_line_items
    line_items.each do |item|
      product = retrieve_stripe_product(item)
      create_order_product(item, product)
      decrement_stock(item, product)
    end
  end

  def create_order_product(item, product)
    OrderProduct.create!(
      order: @order, product_id: product['metadata']['product_id'].to_i,
      quantity: item['quantity'], size: product['metadata']['size'],
      price: product['metadata']['product_price'].to_i
    )
  end

  def decrement_stock(item, product)
    size = product['metadata']['size']
    quantity = item['quantity']

    if size.present?
      Stock.find(product['metadata']['product_stock_id']).decrement!(:stock_level, quantity)
    else
      Product.find(product['metadata']['product_id']).decrement!(:stock_level, quantity)
    end
  end

  def send_confirmation_email
    OrderMailer.new_order_email(@order).deliver_now
  end

  def line_items
    @line_items ||= full_session.line_items['data']
  end

  def full_session
    @full_session ||= Stripe::Checkout::Session.retrieve(id: @stripe_session.id, expand: ['line_items'])
  end

  def retrieve_stripe_product(item)
    product_id = item['price']['product']
    @stripe_products[product_id] ||= Stripe::Product.retrieve(product_id)
  end

  def customer_email = @stripe_session['customer_details']['email']
  def phone = @stripe_session['customer_details']['phone']
  def billing_name = @stripe_session['customer_details']['name']

  def billing_address
    address = @stripe_session['customer_details']&.[]('address')
    return '' unless address

    format_address(address)
  end

  def shipping_address
    collected_information = @stripe_session['collected_information']
    return 'Address not found.' unless collected_information

    address = collected_information['shipping_details']&.[]('address')
    return 'Address not found.' unless address

    format_address(address)
  end

  def shipping_name
    collected_information = @stripe_session['collected_information']
    collected_information&.[]('shipping_details')&.[]('name') || billing_name
  end

  def format_address(address)
    [address['line1'], address['line2'], address['city'],
     address['state'], address['postal_code'], address['country']].compact.reject(&:empty?).join(', ')
  end

  def shipping_cost = @stripe_session['shipping_cost']&.[]('amount_total')
  def shipping_id = @stripe_session['shipping_cost']&.[]('shipping_rate')

  def shipping_description
    return 'Collection' unless shipping_id

    shipping_rate = Stripe::ShippingRate.retrieve(shipping_id)
    shipping_rate['display_name'] || 'Collection'
  end
end
