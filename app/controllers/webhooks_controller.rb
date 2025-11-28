# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_forgery_protection

  def stripe
    event = construct_stripe_event
    return if event.nil?

    handle_event(event)
    render json: { message: 'success' }
  end

  private

  def construct_stripe_event
    configure_stripe
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_KEY'] || Rails.application.credentials.dig(:stripe, :webhook_key)
    Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
  rescue JSON::ParserError, Stripe::SignatureVerificationError => e
    Rails.logger.warn("Webhook verification failed: #{e.class}")
    head :bad_request
    nil
  end

  def configure_stripe
    Stripe.api_key = ENV['STRIPE_SECRET_KEY'] || Rails.application.credentials.dig(:stripe, :secret_key)
  end

  def handle_event(event)
    case event.type
    when 'checkout.session.completed'
      OrderProcessor.new(event.data.object).process
    else
      Rails.logger.info("Unhandled event type: #{event.type}")
    end
  rescue OrderProcessor::ProcessingError => e
    Rails.logger.error("Order processing failed: #{e.message}")
    raise
  end
end
