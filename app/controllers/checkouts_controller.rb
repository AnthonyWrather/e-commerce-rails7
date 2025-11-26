# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class CheckoutsController < ApplicationController
  SHIPPING_OPTIONS = [
    {
      shipping_rate_data: {
        display_name: 'Collection',
        type: 'fixed_amount',
        fixed_amount: {
          amount: 0,
          currency: 'gbp'
        },
        delivery_estimate: {
          minimum: { unit: 'business_day', value: 1 },
          maximum: { unit: 'business_day', value: 1 }
        }
      }
    },
    {
      shipping_rate_data: {
        display_name: '3 to 5 Business Days Shipping',
        type: 'fixed_amount',
        fixed_amount: {
          amount: 2500,
          currency: 'gbp'
        },
        delivery_estimate: {
          minimum: { unit: 'business_day', value: 3 },
          maximum: { unit: 'business_day', value: 5 }
        }
      }
    },
    {
      shipping_rate_data: {
        display_name: 'Overnight Shipping (Order Before 11:00am Mon-Thu)',
        type: 'fixed_amount',
        fixed_amount: {
          amount: 5000,
          currency: 'gbp'
        },
        delivery_estimate: {
          minimum: { unit: 'business_day', value: 1 },
          maximum: { unit: 'business_day', value: 1 }
        }
      }
    }
  ].freeze

  def create
    Stripe.api_key = stripe_secret_key
    line_items = build_line_items(params[:cart])
    return if performed? # Stop if stock validation failed

    session = create_stripe_session(line_items)
    render json: { url: session.url }
  end

  def success
    render :success
  end

  def cancel
    render :cancel
  end

  private

  def stripe_secret_key
    ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key)
  end

  def tax_rate_id
    # UK VAT tax rate - either use existing or create new
    # For production, create this once in Stripe dashboard and store ID in credentials
    ENV['STRIPE_TAX_RATE_ID'] || Rails.application.credentials.dig(:stripe, :tax_rate_id) || create_uk_vat_rate
  end

  def create_uk_vat_rate
    # Create UK VAT rate of 20% (standard rate)
    # This rate is marked as inclusive since our prices already include VAT
    tax_rate = Stripe::TaxRate.create(
      display_name: 'VAT',
      description: 'UK VAT',
      jurisdiction: 'GB',
      percentage: 20.0,
      inclusive: true
    )
    tax_rate.id
  rescue Stripe::StripeError => e
    Rails.logger.error("Failed to create tax rate: #{e.message}")
    # Return nil and handle gracefully - line items will work without tax display
    nil
  end

  def build_line_items(cart)
    cart.map do |item|
      product = Product.find(item['id'])
      product_stock_id, price = get_product_pricing(product, item)

      return unless stock_available?(product, product_stock_id, item)

      build_line_item(item, product, product_stock_id, price)
    end
  end

  def get_product_pricing(product, item)
    product_stock = product.stocks.find { |ps| ps.size == item['size'] }
    if product_stock
      [product_stock.id, product_stock.price]
    else
      [product.id, product.price]
    end
  end

  def stock_available?(product, product_stock_id, item)
    stock_obj = Stock.find_by(id: product_stock_id) if product_stock_id != product.id
    available = stock_obj ? stock_obj.stock_level : product.stock_level

    if available < item['quantity'].to_i
      size_text = item['size'].present? ? " in size #{item['size']}" : ''
      render json: { error: "Not enough stock for #{product.name}#{size_text}. Only #{available} left." }, status: 400
      return false
    end
    true
  end

  def build_line_item(item, product, product_stock_id, price)
    line_item = {
      quantity: item['quantity'].to_i,
      price_data: {
        product_data: {
          name: item['name'],
          metadata: { product_id: product.id, size: item['size'], product_stock_id: product_stock_id, product_price: price }
        },
        currency: 'gbp',
        unit_amount: item['price'].to_i,
        tax_behavior: 'inclusive'
      }
    }

    # Add tax rate if available
    tax_id = tax_rate_id
    line_item[:tax_rates] = [tax_id] if tax_id.present?

    line_item
  end

  def create_stripe_session(line_items)
    Stripe::Checkout::Session.create(
      mode: 'payment',
      line_items: line_items,
      success_url: "#{request.protocol}#{request.host_with_port}/success",
      cancel_url: "#{request.protocol}#{request.host_with_port}/cart",
      shipping_address_collection: { allowed_countries: %w[GB] },
      currency: 'GBP',
      payment_method_types: ['card'],
      phone_number_collection: { enabled: true },
      billing_address_collection: 'required',
      shipping_options: SHIPPING_OPTIONS
    )
  end
end
# rubocop:enable Metrics/ClassLength
