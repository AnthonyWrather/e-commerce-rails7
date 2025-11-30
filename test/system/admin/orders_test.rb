# frozen_string_literal: true

require 'application_system_test_case'

module Admin
  class OrdersTest < ApplicationSystemTestCase
    setup do
      sign_in_admin
      @admin_order = orders(:order_one)
      @unfulfilled_order = orders(:order_one)
      @fulfilled_order = orders(:order_two)
    end

    test 'visiting the index' do
      visit admin_orders_url
      assert_selector 'h1', text: 'Orders'
    end

    test 'should create order' do
      visit admin_orders_url
      click_on 'New order'

      fill_in 'Address', with: @admin_order.address
      fill_in 'Customer email', with: @admin_order.customer_email
      fill_in 'Name', with: @admin_order.name
      check 'Fulfilled' if @admin_order.fulfilled
      fill_in 'Total', with: @admin_order.total
      click_on 'Create Order'

      assert_text 'Order was successfully created'
      click_on 'Back'
    end

    test 'should update Order' do
      visit admin_order_url(@admin_order)
      click_on 'Edit this admin_order', match: :first

      fill_in 'Address', with: @admin_order.address
      fill_in 'Customer email', with: @admin_order.customer_email
      check 'Fulfilled' if @admin_order.fulfilled
      fill_in 'Total', with: @admin_order.total
      click_on 'Update Order'

      assert_text 'Order was successfully updated'
      click_on 'Back'
    end

    # Order Fulfillment Workflow Tests
    test 'index shows unfulfilled orders section' do
      visit admin_orders_url

      assert_selector 'h2', text: 'Unfulfilled Orders'
      assert_text @unfulfilled_order.customer_email
    end

    test 'index shows fulfilled orders section' do
      visit admin_orders_url

      assert_selector 'h2', text: 'Fulfilled Orders'
      assert_text @fulfilled_order.customer_email
    end

    test 'admin can view order details' do
      visit admin_orders_url

      click_link @unfulfilled_order.id.to_s
      assert_text 'Invoice Details'
      assert_text @unfulfilled_order.customer_email
      assert_text @unfulfilled_order.name
      assert_text @unfulfilled_order.address
    end

    test 'admin can mark order as fulfilled' do
      visit admin_order_url(@unfulfilled_order)
      click_on 'Edit this admin_order', match: :first

      check 'Fulfilled'
      click_on 'Update Order'

      assert_text 'Order was successfully updated'
      assert_text 'Yes'
    end

    test 'admin can mark order as unfulfilled' do
      visit admin_order_url(@fulfilled_order)
      click_on 'Edit this admin_order', match: :first

      uncheck 'Fulfilled'
      click_on 'Update Order'

      assert_text 'Order was successfully updated'
    end

    test 'order shows payment status' do
      visit admin_order_url(@admin_order)

      assert_text 'Payment Status'
      assert_text 'Paid'
    end

    test 'order shows shipping information' do
      visit admin_order_url(@admin_order)

      assert_text 'Shipping'
    end

    test 'order shows total with shipping' do
      visit admin_order_url(@admin_order)

      assert_text 'Total (Inc Shipping and VAT)'
    end

    test 'admin can navigate back to orders list from details' do
      visit admin_order_url(@admin_order)

      click_link 'Back to admin_orders'
      assert_selector 'h1', text: 'Orders'
    end

    test 'order list shows order date' do
      visit admin_orders_url

      assert_text @unfulfilled_order.created_at.strftime('%d %B %Y')
    end

    test 'order list shows customer name' do
      visit admin_orders_url

      assert_text @unfulfilled_order.name
    end

    test 'order list shows order total' do
      visit admin_orders_url

      assert_text '£150.00'
    end

    test 'can create new order from index' do
      visit admin_orders_url

      click_on 'New order'
      assert_selector 'h1', text: 'New order'
    end

    test 'order details show billing information' do
      visit admin_order_url(@admin_order)

      assert_text 'Billing Name'
      assert_text 'Billing Address'
    end

    test 'order details show stripe payment id' do
      visit admin_order_url(@admin_order)

      assert_text 'Stripe Payment ID'
      assert_text @admin_order.payment_id
    end
  end
end
