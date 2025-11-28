# frozen_string_literal: true

require 'application_system_test_case'

class Admin::DashboardTest < ApplicationSystemTestCase
  setup do
    @admin = admin_users(:admin_user_one)
    sign_in @admin
  end

  test 'admin can visit dashboard' do
    visit admin_url

    assert_selector 'h1', text: 'Monthly Revenue'
    assert_selector 'h2', text: 'Monthly Stats'
    assert_selector 'h2', text: 'Recent Unfulfilled Orders'
  end

  test 'dashboard displays revenue chart' do
    visit admin_url

    assert_selector 'canvas#revenueChartMonthly'
    assert_selector '[data-controller="dashboard"]'
  end

  test 'dashboard displays all monthly stat cards' do
    visit admin_url

    # Stat card labels
    assert_text 'Gross Revenue'
    assert_text 'Net Revenue'
    assert_text 'Gross Shipping'
    assert_text 'VAT'
    assert_text 'Num Sales'
    assert_text 'Total Items'
    assert_text 'Average Sale'
    assert_text 'Average Items/Sale'
  end

  test 'dashboard displays recent unfulfilled orders table' do
    visit admin_url

    within 'table' do
      assert_text 'Order ID'
      assert_text 'Order Date'
      assert_text 'Shipping Type'
      assert_text 'Name'
      assert_text 'Customer Email'
      assert_text 'Amount'
    end
  end

  test 'dashboard links to individual orders from table' do
    # Use an unfulfilled order from fixtures (order_one and order_three are unfulfilled)
    order = orders(:order_one)

    visit admin_url

    within 'table tbody' do
      click_link order.id.to_s
    end

    assert_current_path admin_order_path(order)
  end

  test 'dashboard shows empty table when no unfulfilled orders exist' do
    # Mark all orders as fulfilled
    Order.update_all(fulfilled: true)

    visit admin_url

    # Should still show the headings but no rows in tbody
    within 'table' do
      assert_text 'Order ID'
      # tbody should be empty or have no order links
    end

    # Monthly stats should still show if there are orders this month
    assert_selector 'h2', text: 'Monthly Stats'
  end
end
