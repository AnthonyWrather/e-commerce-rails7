# frozen_string_literal: true

class Api::CartsController < ApplicationController
  skip_forgery_protection

  before_action :set_cart_service

  def show
    cart_data = @cart_service.to_local_storage_format
    render json: { items: cart_data, expires_at: @cart_service.cart.expires_at }
  end

  def sync
    @cart_service.sync_from_local_storage(cart_params[:items] || [])
    cart_data = @cart_service.to_local_storage_format
    render json: { items: cart_data, expires_at: @cart_service.cart.expires_at }
  rescue CartPersistenceService::PersistenceError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def merge
    @cart_service.merge_carts(cart_params[:items] || [])
    cart_data = @cart_service.to_local_storage_format
    render json: { items: cart_data, expires_at: @cart_service.cart.expires_at }
  rescue CartPersistenceService::PersistenceError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  end

  def clear
    @cart_service.clear_cart
    render json: { items: [], message: 'Cart cleared' }
  end

  private

  def set_cart_service
    token = request.headers['X-Cart-Token'] || session_token_from_params
    return render json: { error: 'Cart token required' }, status: :bad_request if token.blank?

    @cart_service = CartPersistenceService.new(token)
  end

  def session_token_from_params
    params[:session_token] || params[:cart_token]
  end

  def cart_params
    params.permit(:session_token, :cart_token, items: %i[id product_id name price size quantity])
  end
end
