# frozen_string_literal: true

require 'test_helper'

module Admin
  class OrdersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin_order = orders(:order_one)
      sign_in admin_users(:admin_user_one)
    end

    test 'should get index' do
      get admin_orders_url
      assert_response :success
    end

    test 'should get new' do
      get new_admin_order_url
      assert_response :success
    end

    test 'should create admin_order' do
      assert_difference('Order.count') do
        post admin_orders_url,
             params: { order: { address: @admin_order.address, customer_email: @admin_order.customer_email,
                                fulfilled: @admin_order.fulfilled, total: @admin_order.total } }
      end

      assert_redirected_to admin_order_url(Order.last)
    end

    test 'should show admin_order' do
      get admin_order_url(@admin_order)
      assert_response :success
    end

    test 'should get edit' do
      get edit_admin_order_url(@admin_order)
      assert_response :success
    end

    test 'should update admin_order' do
      patch admin_order_url(@admin_order),
            params: { order: { address: @admin_order.address, customer_email: @admin_order.customer_email,
                               fulfilled: @admin_order.fulfilled, total: @admin_order.total } }
      assert_redirected_to admin_order_url(@admin_order)
    end

    test 'should destroy admin_order' do
      order_to_delete = orders(:order_three)
      assert_difference('Order.count', -1) do
        delete admin_order_url(order_to_delete)
      end

      assert_redirected_to admin_orders_url
    end
  end
end
