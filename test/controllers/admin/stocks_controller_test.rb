# frozen_string_literal: true

require 'test_helper'

module Admin
  class StocksControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin_stock = stocks(:stock_one)
      @product = products(:product_one)
      sign_in admin_users(:admin_user_one)
    end

    test 'should get index' do
      get admin_product_stocks_url(@product)
      assert_response :success
    end

    test 'should get new' do
      get new_admin_product_stock_url(@product)
      assert_response :success
    end

    test 'should create admin_stock' do
      assert_difference('Stock.count') do
        post admin_product_stocks_url(@product),
             params: { stock: { stock_level: @admin_stock.stock_level, product_id: @admin_stock.product_id,
                                size: @admin_stock.size, price: @admin_stock.price } }
      end

      assert_redirected_to admin_product_stock_url(@product, Stock.last)
    end

    test 'should show admin_stock' do
      get admin_product_stock_url(@product, @admin_stock)
      assert_response :success
    end

    test 'should get edit' do
      get edit_admin_product_stock_url(@product, @admin_stock)
      assert_response :success
    end

    test 'should update admin_stock' do
      patch admin_product_stock_url(@product, @admin_stock),
            params: { stock: { stock_level: @admin_stock.stock_level, product_id: @admin_stock.product_id,
                               size: @admin_stock.size } }
      assert_redirected_to admin_product_stock_url(@product, @admin_stock)
    end

    test 'should destroy admin_stock' do
      assert_difference('Stock.count', -1) do
        delete admin_product_stock_url(@product, @admin_stock)
      end

      assert_redirected_to admin_product_stocks_url(@product)
    end
  end
end
