# frozen_string_literal: true

require 'test_helper'

class Users::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test 'should get index' do
    get orders_url
    assert_response :success
    assert_select 'h1', 'Order History'
  end

  test 'should require authentication for index' do
    sign_out @user
    # Since routes are wrapped in authenticated :user block,
    # unauthenticated requests get 404
    get '/orders'
    assert_response :not_found
  end

  test 'should show message when no orders exist' do
    get orders_url
    assert_response :success
    assert_match "haven't placed any orders", response.body
  end

  test 'should list user orders' do
    # Create orders for the user
    Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 10_000,
      fulfilled: false
    )

    Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 20_000,
      fulfilled: true
    )

    get orders_url
    assert_response :success
    assert_select 'table tbody tr', count: 2
  end

  test 'should show order details' do
    order = Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St, London, SW1A 1AA',
      total: 15_000,
      fulfilled: false,
      shipping_cost: 500
    )

    product = products(:product_one)
    OrderProduct.create!(
      order: order,
      product: product,
      quantity: 2,
      price: 7_000
    )

    get order_url(order)
    assert_response :success
    assert_match "Order ##{order.id}", response.body
    assert_match 'John Smith', response.body
    assert_match '123 Test St', response.body
  end

  test 'should not access other users orders' do
    other_user = users(:user_two)
    other_order = Order.create!(
      user: other_user,
      customer_email: other_user.email,
      name: 'Jane Doe',
      address: '456 Other St',
      total: 5_000,
      fulfilled: false
    )

    get order_url(other_order)
    assert_response :not_found
  end

  test 'should display order status correctly' do
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
      total: 10_000,
      fulfilled: false
    )

    get orders_url
    assert_response :success
    assert_select 'span.bg-green-100', 'Fulfilled'
    assert_select 'span.bg-yellow-100', 'Processing'
  end

  test 'should paginate orders' do
    # Create many orders
    12.times do |i|
      Order.create!(
        user: @user,
        customer_email: @user.email,
        name: 'John Smith',
        address: '123 Test St',
        total: 1_000 * (i + 1),
        fulfilled: false
      )
    end

    get orders_url
    assert_response :success
    # Default page size is 10
    assert_select 'table tbody tr', count: 10
  end

  test 'should display order products on show page' do
    order = Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 15_000,
      fulfilled: false
    )

    product = products(:product_one)
    OrderProduct.create!(
      order: order,
      product: product,
      quantity: 2,
      size: 'Medium',
      price: 7_500
    )

    get order_url(order)
    assert_response :success
    assert_match product.name, response.body
    assert_match 'Medium', response.body
    assert_match 'Qty: 2', response.body
  end

  test 'should display shipping information when available' do
    order = Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 15_000,
      fulfilled: false,
      shipping_cost: 500,
      shipping_description: 'Standard Delivery'
    )

    get order_url(order)
    assert_response :success
    assert_match 'Standard Delivery', response.body
  end

  test 'should display billing address when different from shipping' do
    order = Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      billing_name: 'John Smith Corp',
      billing_address: '456 Business Lane',
      total: 15_000,
      fulfilled: false
    )

    get order_url(order)
    assert_response :success
    assert_match 'Billing Address', response.body
    assert_match 'John Smith Corp', response.body
  end
end
