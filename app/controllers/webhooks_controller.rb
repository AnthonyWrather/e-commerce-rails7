# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_forgery_protection

  def stripe
    stripe_secret_key = ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key)
    Stripe.api_key = stripe_secret_key
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_KEY'] || Rails.application.credentials.dig(:stripe, :webhook_key)
    event = nil

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
      status 400
      return
    rescue Stripe::SignatureVerificationError
      puts 'Webhook signature verification failed.'
      status 400
      return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      collected_information = session['collected_information']
      customer_details = session['customer_details']
      puts '---------------------------------------------'
      puts "Session: #{session}"
      puts '---------------------------------------------'
      if collected_information
        address = "#{collected_information['shipping_details']['address']['line1']}, #{collected_information['shipping_details']['address']['line2']}, #{collected_information['shipping_details']['address']['city']}, #{collected_information['shipping_details']['address']['state']}, #{collected_information['shipping_details']['address']['postal_code']}, #{collected_information['shipping_details']['address']['country']}"
      else
        address = 'Address not found.'
      end

      phone = session['customer_details']['phone']
      billing_address = "#{customer_details['address']['line1']}, #{customer_details['address']['line2']}, #{customer_details['address']['city']}, #{customer_details['address']['state']}, #{customer_details['address']['postal_code']}, #{customer_details['address']['country']}"
      billing_name = session['customer_details']['name']

      order = Order.create!(customer_email: session['customer_details']['email'], total: session['amount_total'],
                            address: address, fulfilled: false, name: collected_information['shipping_details']['name'],
                            phone: phone, billing_name: billing_name, billing_address: billing_address)
      full_session = Stripe::Checkout::Session.retrieve({
                                                          id: session.id,
                                                          expand: ['line_items']
                                                        })
      line_items = full_session.line_items
      line_items['data'].each do |item|
        product = Stripe::Product.retrieve(item['price']['product'])
        product_id = product['metadata']['product_id'].to_i
        OrderProduct.create!(order: order, product_id: product_id, quantity: item['quantity'],
                             size: product['metadata']['size'])
        if (product['metadata']['size']) && (product['metadata']['size']).length.positive?
          Stock.find(product['metadata']['product_stock_id']).decrement!(:amount, item['quantity'])
        else
          Product.find(product['metadata']['product_id']).decrement!(:amount, item['quantity'])
        end
      end
      OrderMailer.new_order_email(order).deliver_now
    else
      puts '---------------------------------------------'
      puts "Unhandled event type: #{event.type}"
      puts '---------------------------------------------'
    end

    render json: { message: 'success' }
  end
end
