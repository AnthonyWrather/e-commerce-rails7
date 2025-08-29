# frozen_string_literal: true

class CheckoutsController < ApplicationController
  def create
    stripe_secret_key = Rails.application.credentials.dig(:stripe, :secret_key)
    Stripe.api_key = stripe_secret_key
    cart = params[:cart]
    line_items = cart.map do |item|
      product = Product.find(item['id'])
      product_stock_id = product.id

      product_stock = product.stocks.find { |ps| ps.size == item['size'] }
      if product_stock
        product_stock_id = product_stock.id
      end

      if product_stock && product_stock.amount <= item['quantity'].to_i
        render json: { error: "Not enough stock for #{product.name} in size #{item['size']}. Only #{product_stock.amount} left." },
               status: 400
        return
      elsif product.amount <= item['quantity'].to_i
        render json: { error: "Not enough stock for #{product.name} in size #{item['size']}. Only #{product.amount} left." },
               status: 400
        return
      end

      {
        quantity: item['quantity'].to_i,
        price_data: {
          product_data: {
            name: item['name'],
            # metadata: { product_id: product.id, size: item['size'], product_stock_id: product_stock.id }
            metadata: { product_id: product.id, size: item['size'], product_stock_id: product_stock_id }
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
      cancel_url: "#{request.protocol}#{request.host_with_port}/cancel",
      shipping_address_collection: {
        allowed_countries: %w[GB]
      }
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
