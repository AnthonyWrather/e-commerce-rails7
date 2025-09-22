# frozen_string_literal: true

class CheckoutsController < ApplicationController
  def create
    stripe_secret_key = ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key)
    Stripe.api_key = stripe_secret_key
    cart = params[:cart]
    line_items = cart.map do |item|
      product = Product.find(item['id'])
      product_stock_id = product.id
      price = product.price

      product_stock = product.stocks.find { |ps| ps.size == item['size'] }
      if product_stock
        product_stock_id = product_stock.id
        price = product_stock.price
      end

      if product_stock && product_stock.amount < item['quantity'].to_i
        render json: { error: "Not enough stock for #{product.name} in size #{item['size']}. Only #{product_stock.amount} left." },
               status: 400
        return
      elsif !product_stock && product.amount < item['quantity'].to_i
        render json: { error: "Not enough stock for #{product.name} in size #{item['size']}. Only #{product.amount} left." },
               status: 400
        return
      end

      {
        quantity: item['quantity'].to_i,
        price_data: {
          product_data: {
            name: item['name'],
            metadata: { product_id: product.id, size: item['size'], product_stock_id: product_stock_id, product_price: price }
          },
          currency: 'gbp',
          unit_amount: item['price'].to_i
        }
      }
    end

    puts "line_items: #{line_items}"

    session = Stripe::Checkout::Session.create(
      mode: 'payment',
      line_items: line_items,
      success_url: "#{request.protocol}#{request.host_with_port}/success",
      cancel_url: "#{request.protocol}#{request.host_with_port}/cart",
      shipping_address_collection: {
        allowed_countries: %w[GB]
      },
      currency: 'GBP',
      payment_method_types: ['card'],
      phone_number_collection: {
        enabled: true
      },
      billing_address_collection: 'required',
      shipping_options: [
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
              maximum: { unit: 'business_day', value: 1 },
            }
          }
        },
        {
          shipping_rate_data: {
            display_name: '3 to 5 Days Shipping',
            type: 'fixed_amount',
            fixed_amount: {
              amount: 2500,
              currency: 'gbp'
            },
            delivery_estimate: {
              minimum: { unit: 'business_day', value: 3 },
              maximum: { unit: 'business_day', value: 5 },
            }
          }
        },
        {
          shipping_rate_data: {
            display_name: 'Overnight Shipping (Order Before 11:00am)',
            type: 'fixed_amount',
            fixed_amount: {
              amount: 5000,
              currency: 'gbp'
            },
            delivery_estimate: {
              minimum: { unit: 'business_day', value: 1 },
              maximum: { unit: 'business_day', value: 1 },
            }
          }
        }

      ]
    )

    render json: { url: session.url }
  end

  def success
    render :success
  end

  def cancel
    render :cancel
  end
end
