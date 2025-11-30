# frozen_string_literal: true

require 'application_system_test_case'

class OrderHistoryTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test 'user sees empty order history message when no orders' do
    visit orders_path

    assert_selector 'h1', text: 'Order History'
    assert_text "haven't placed any orders"
  end

  test 'user can view order history with orders' do
    # Create an order for the user
    order = Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St, London, SW1A 1AA',
      total: 15_000,
      fulfilled: false
    )

    visit orders_path

    assert_selector 'h1', text: 'Order History'
    assert_selector 'table'
    assert_text "##{order.id}"
    assert_text '£150.00'
    assert_text 'Processing'
  end

  test 'user can view order details' do
    order = Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St, London, SW1A 1AA',
      total: 15_000,
      fulfilled: true,
      shipping_cost: 500,
      payment_status: 'paid'
    )

    product = products(:product_one)
    OrderProduct.create!(
      order: order,
      product: product,
      quantity: 2,
      price: 7_500
    )

    visit orders_path
    click_link 'View Details'

    assert_text "Order ##{order.id}"
    assert_text 'Fulfilled'
    assert_text 'John Smith'
    assert_text product.name
    assert_text 'Qty: 2'
    assert_text 'Paid'
  end

  test 'user can navigate back to order list from details' do
    order = Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 10_000,
      fulfilled: false
    )

    visit order_path(order)

    click_link 'Back to Order History'
    assert_selector 'h1', text: 'Order History'
  end

  test 'order status is displayed correctly' do
    Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 10_000,
      fulfilled: true
    )

    Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 20_000,
      fulfilled: false
    )

    visit orders_path

    assert_selector 'span', text: 'Fulfilled'
    assert_selector 'span', text: 'Processing'
  end

  test 'user can navigate from dashboard to order history' do
    visit account_path

    click_link 'Order History'
    assert_selector 'h1', text: 'Order History'
  end
end
