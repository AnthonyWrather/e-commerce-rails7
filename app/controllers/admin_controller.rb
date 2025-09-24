# frozen_string_literal: true

class AdminController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin!

  def index
    @orders = Order.where(fulfilled: false).order(created_at: :desc).take(5)

    # Monthly Revenue Chart Data
    num_orders_monthly = Order.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).count
    num_products_monthly = OrderProduct.joins(:order).where(orders: { created_at: Time.now.beginning_of_month..Time.now.end_of_month }).sum(:quantity)
    avg_items_monthly = 0
    if num_orders_monthly.positive? && num_products_monthly.positive?
      avg_items_monthly = num_products_monthly.div(num_orders_monthly)
    end

    @monthly_stats = {
      sales: num_orders_monthly,
      items: num_products_monthly,
      revenue: Order.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).sum(:total)&.round(),
      avg_sale: Order.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).average(:total)&.round(),
      shipping: Order.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).where.not(shipping_cost: nil).sum(:shipping_cost)&.round(),
      per_sale: avg_items_monthly
    }

    @monthly_orders_by_day = Order.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).order(:created_at)
    @monthly_orders_by_day = @monthly_orders_by_day.group_by { |order| order.created_at.to_date }
    @monthly_revenue_by_day = @monthly_orders_by_day.map { |day, orders| [day.strftime('%e %A'), orders.sum(&:total)] }
    @days_of_month = (1..Time.days_in_month(Date.today.month, Date.today.year)).to_a
    @monthly_revenue_by_day = @monthly_revenue_by_day.to_h
    @revenue_by_month = @days_of_month.map { |day| [day, @monthly_revenue_by_day.fetch(Date.new(Date.today.year, Date.today.month, day).strftime('%e %A'), 0)] }
  end
end
