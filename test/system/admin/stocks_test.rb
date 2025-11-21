# frozen_string_literal: true

require 'application_system_test_case'

module Admin
  class StocksTest < ApplicationSystemTestCase
    setup do
      sign_in_admin
      @admin_stock = stocks(:stock_one)
      @product = @admin_stock.product
    end

    test 'visiting the index' do
      visit admin_product_stocks_url(@product)
      assert_selector 'h1', text: 'Stocks'
    end

    test 'should create stock' do
      visit admin_product_stocks_url(@product)
      click_on 'New stock'

      fill_in 'Size', with: @admin_stock.size
      fill_in 'Price', with: @admin_stock.price
      fill_in 'Amount', with: @admin_stock.amount
      click_on 'Create Stock'

      assert_text 'Stock was successfully created'
      click_on 'Back'
    end

    test 'should update Stock' do
      visit admin_product_stock_url(@product, @admin_stock)
      click_on 'Edit this admin_stock', match: :first

      click_button 'Update Stock'

      assert_text 'Stock was successfully updated'
    end

    test 'should destroy Stock' do
      visit admin_product_stock_url(@product, @admin_stock)
      click_on 'Destroy this admin_stock', match: :first

      assert_text 'Stock was successfully destroyed'
    end
  end
end
