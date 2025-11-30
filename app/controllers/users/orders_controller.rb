# frozen_string_literal: true

class Users::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show]
  layout 'user_dashboard'

  include Pagy::Backend

  rescue_from ActiveRecord::RecordNotFound, with: :order_not_found

  def index
    @pagy, @orders = pagy(current_user.orders.order(created_at: :desc), items: 10)
  end

  def show
    @order_products = @order.order_products.includes(:product)
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_not_found
    head :not_found
  end
end
