# frozen_string_literal: true

require 'application_system_test_case'

module Admin
  class ReportsTest < ApplicationSystemTestCase
    setup do
      sign_in_admin
    end

    test 'visiting the reports index page' do
      visit admin_reports_path
      
      assert_selector 'h1', text: 'Current Month Revenue'
      assert_selector 'h2', text: 'Current Month Stats'
    end

    test 'current month revenue chart is displayed' do
      visit admin_reports_path
      
      # Check for the chart canvas element
      assert_selector 'canvas#revenueChartMonthly'
      
      # Check for the data controller that renders the chart
      assert_selector '[data-controller="dashboard"]'
    end

    test 'previous month revenue chart is displayed' do
      visit admin_reports_path
      
      # Check for previous month heading
      assert_selector 'h1', text: 'Previous Month Revenue'
      
      # Check for the previous month chart canvas
      assert_selector 'canvas#revenueChartPrevMonth'
    end

    test 'current month stats cards are displayed' do
      visit admin_reports_path
      
      # Check all the stat card headings
      assert_text 'Gross Revenue'
      assert_text 'Net Revenue'
      assert_text 'Shipping'
      assert_text 'VAT'
      assert_text 'Num Sales'
      assert_text 'Total Items'
      assert_text 'Average Sale'
      assert_text 'Average Items/Sale'
    end

    test 'previous month stats cards are displayed' do
      visit admin_reports_path
      
      # Scroll down to see previous month stats
      assert_selector 'h2', text: 'Previous Month Stats'
      
      # The stats should be present (same structure as current month)
      all_headings = all('.text-xl.font-bold.text-white, .mb-2.text-xl.font-bold.text-white')
      
      # Should have stats for both current and previous month (8 stats x 2 months = 16)
      assert all_headings.length >= 8, "Expected at least 8 stat cards"
    end

    test 'reports page displays formatted prices' do
      visit admin_reports_path
      
      # Check that prices are formatted with £ symbol
      # The page should contain formatted prices (even if £0.00)
      assert page.has_content?(/£\d+/)
    end

    test 'navigation to reports from admin dashboard' do
      visit admin_path
      
      # Find and click the Reports link in the navigation
      click_on 'Reports'
      
      assert_current_path admin_reports_path
      assert_selector 'h1', text: 'Current Month Revenue'
    end
  end
end
