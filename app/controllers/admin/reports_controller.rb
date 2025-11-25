# frozen_string_literal: true

class Admin::ReportsController < AdminController
  def index
    # Calculate month ranges once to avoid repeated calculations
    current_month_start = Time.now.beginning_of_month
    current_month_end = Time.now.end_of_month
    prev_month_start = 1.month.ago.beginning_of_month
    prev_month_end = 1.month.ago.end_of_month

    # Current Month: Combine all Order aggregations into a single efficient query
    current_month_aggregates = Order
                               .where(created_at: current_month_start..current_month_end)
                               .pluck(
                                 Arel.sql('COUNT(*)'),
                                 Arel.sql('COALESCE(SUM(total), 0)'),
                                 Arel.sql('COALESCE(AVG(total), 0)'),
                                 Arel.sql('COALESCE(SUM(CASE WHEN shipping_cost IS NOT NULL THEN shipping_cost ELSE 0 END), 0)')
                               ).first || [0, 0, 0, 0]

    num_orders_monthly = current_month_aggregates[0]
    revenue_total = current_month_aggregates[1].to_i.round
    avg_sale = current_month_aggregates[2].to_i.round
    shipping_total = current_month_aggregates[3].to_i.round

    # Get total items sold for current month
    num_products_monthly = OrderProduct
                           .joins(:order)
                           .where(orders: { created_at: current_month_start..current_month_end })
                           .sum(:quantity)

    avg_items_monthly = if num_orders_monthly.positive? && num_products_monthly.positive?
                          num_products_monthly.div(num_orders_monthly)
                        else
                          0
                        end

    @monthly_stats = {
      sales: num_orders_monthly,
      items: num_products_monthly,
      revenue: revenue_total,
      avg_sale: avg_sale,
      shipping: shipping_total,
      per_sale: avg_items_monthly
    }

    # Optimize daily revenue breakdown using database-level GROUP BY
    daily_revenue = Order
                    .where(created_at: current_month_start..current_month_end)
                    .group(Arel.sql('DATE(created_at)'))
                    .pluck(Arel.sql('DATE(created_at)'), Arel.sql('SUM(total)'))
                    .to_h # Fill in missing days with zero revenue for current month
    days_current_month = (1..Time.days_in_month(Date.today.month, Date.today.year)).to_a
    @revenue_by_month = days_current_month.map do |day|
      date = Date.new(Date.today.year, Date.today.month, day)
      revenue = daily_revenue[date] || 0
      [day, revenue]
    end

    # Previous Month: Same efficient aggregation pattern
    prev_month_aggregates = Order
                            .where(created_at: prev_month_start..prev_month_end)
                            .pluck(
                              Arel.sql('COUNT(*)'),
                              Arel.sql('COALESCE(SUM(total), 0)'),
                              Arel.sql('COALESCE(AVG(total), 0)'),
                              Arel.sql('COALESCE(SUM(CASE WHEN shipping_cost IS NOT NULL THEN shipping_cost ELSE 0 END), 0)')
                            ).first || [0, 0, 0, 0]

    num_orders_prev_month = prev_month_aggregates[0]
    revenue_total_prev = prev_month_aggregates[1].to_i.round
    avg_sale_prev = prev_month_aggregates[2].to_i.round
    shipping_total_prev = prev_month_aggregates[3].to_i.round # Get total items sold for previous month
    num_products_prev_month = OrderProduct
                              .joins(:order)
                              .where(orders: { created_at: prev_month_start..prev_month_end })
                              .sum(:quantity)

    avg_items_prev_month = if num_orders_prev_month.positive? && num_products_prev_month.positive?
                             num_products_prev_month.div(num_orders_prev_month)
                           else
                             0
                           end

    @prev_month_stats = {
      sales: num_orders_prev_month,
      items: num_products_prev_month,
      revenue: revenue_total_prev,
      avg_sale: avg_sale_prev,
      shipping: shipping_total_prev,
      per_sale: avg_items_prev_month
    }

    # Optimize previous month daily revenue breakdown
    daily_revenue_prev = Order
                         .where(created_at: prev_month_start..prev_month_end)
                         .group(Arel.sql('DATE(created_at)'))
                         .pluck(Arel.sql('DATE(created_at)'), Arel.sql('SUM(total)'))
                         .to_h # Fill in missing days with zero revenue for previous month
    days_prev_month = (1..Time.days_in_month(1.month.ago.month, 1.month.ago.year)).to_a
    @revenue_by_prev_month = days_prev_month.map do |day|
      date = Date.new(1.month.ago.year, 1.month.ago.month, day)
      revenue = daily_revenue_prev[date] || 0
      [day, revenue]
    end
  end
end
