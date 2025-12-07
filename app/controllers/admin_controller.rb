# frozen_string_literal: true

class AdminController < ApplicationController
  layout 'admin'
  before_action :authenticate_admin_user!
  after_action :discard_flash, if: -> { response.successful? }

  def index
    # Use indexed column for better query performance
    @orders = Order.unfulfilled.recent(5)

    # Cache dashboard stats for 5 minutes to reduce database load
    # Stats are tied to current month, so cache key includes month
    cache_key = "admin_dashboard_stats_#{Date.today.strftime('%Y-%m')}"

    @monthly_stats, @revenue_by_month, @days_of_month = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      calculate_monthly_stats
    end
  end

  private

  def calculate_monthly_stats
    # Combine all Order aggregations into a single efficient query
    # This reduces 5 separate queries to 1 query
    monthly_aggregates = Order
                         .for_month
                         .pluck(
                           Arel.sql('COUNT(*)'),
                           Arel.sql('COALESCE(SUM(total), 0)'),
                           Arel.sql('COALESCE(AVG(total), 0)'),
                           Arel.sql('COALESCE(SUM(CASE WHEN shipping_cost IS NOT NULL THEN shipping_cost ELSE 0 END), 0)')
                         ).first || [0, 0, 0, 0]

    num_orders_monthly = monthly_aggregates[0]
    revenue_total = monthly_aggregates[1].to_i.round
    avg_sale = monthly_aggregates[2].to_i.round
    shipping_total = monthly_aggregates[3].to_i.round

    # Calculate month range for the OrderProduct query
    current_month_start = Time.current.beginning_of_month
    current_month_end = Time.current.end_of_month

    # Get total items sold in a single join query
    num_products_monthly = OrderProduct
                           .joins(:order)
                           .where(orders: { created_at: current_month_start..current_month_end })
                           .sum(:quantity)

    # Calculate average items per sale
    avg_items_monthly = if num_orders_monthly.positive? && num_products_monthly.positive?
                          num_products_monthly.div(num_orders_monthly)
                        else
                          0
                        end

    monthly_stats = {
      sales: num_orders_monthly,
      items: num_products_monthly,
      revenue: revenue_total,
      avg_sale: avg_sale,
      shipping: shipping_total,
      per_sale: avg_items_monthly
    }

    # Optimize daily revenue breakdown using database-level GROUP BY
    # This replaces loading all orders into memory and grouping in Ruby
    daily_revenue = Order
                    .for_month
                    .group(Arel.sql('DATE(created_at)'))
                    .pluck(Arel.sql('DATE(created_at)'), Arel.sql('SUM(total)'))
                    .to_h

    # Fill in missing days with zero revenue
    days_of_month = (1..Time.days_in_month(Date.today.month, Date.today.year)).to_a
    revenue_by_month = days_of_month.map do |day|
      date = Date.new(Date.today.year, Date.today.month, day)
      revenue = daily_revenue[date] || 0
      [day, revenue]
    end

    [monthly_stats, revenue_by_month, days_of_month]
  end

  # Discard flash messages after they've been rendered on successful responses.
  # This ensures flash messages only appear once and don't persist across page navigations.
  # Only called for successful responses (200-299 status codes), not redirects.
  def discard_flash
    # Delete all flash keys immediately to prevent persistence
    # rubocop:disable Style/HashEachMethods
    flash.keys.each { |key| flash.delete(key) } # FlashHash doesn't implement each_key
    # rubocop:enable Style/HashEachMethods
  end
end
