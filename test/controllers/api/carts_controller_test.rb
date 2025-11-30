# frozen_string_literal: true

require 'test_helper'

class Api::CartsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @cart = carts(:cart_one)
    @product = products(:product_one)
    @product_two = products(:product_two)
  end

  test 'show returns cart items' do
    get api_cart_path, headers: { 'X-Cart-Token' => @cart.session_token }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.key?('items')
    assert json_response.key?('expires_at')
    assert json_response['items'].is_a?(Array)
  end

  test 'show returns bad request without token' do
    get api_cart_path

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal 'Cart token required', json_response['error']
  end

  test 'show accepts token from params' do
    get api_cart_path, params: { session_token: @cart.session_token }

    assert_response :success
  end

  test 'sync creates new cart items' do
    token = 'sync_test_token_123'
    items_data = [
      { id: @product.id, name: @product.name, price: @product.price, size: '', quantity: 2 }
    ]

    post sync_api_cart_path,
         params: { items: items_data },
         headers: { 'X-Cart-Token' => token },
         as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response['items'].length
  end

  test 'sync updates existing cart items' do
    existing_item = @cart.cart_items.first
    items_data = [
      { id: existing_item.product_id, size: existing_item.size, quantity: 99 }
    ]

    post sync_api_cart_path,
         params: { items: items_data },
         headers: { 'X-Cart-Token' => @cart.session_token },
         as: :json

    assert_response :success
    existing_item.reload
    assert_equal 99, existing_item.quantity
  end

  test 'sync returns bad request without token' do
    post sync_api_cart_path, params: { items: [] }, as: :json

    assert_response :bad_request
  end

  test 'merge adds new items to cart' do
    initial_count = @cart.cart_items.count
    items_data = [
      { product_id: @product_two.id, size: 'merge_test_size', quantity: 3, price: @product_two.price }
    ]

    post merge_api_cart_path,
         params: { items: items_data },
         headers: { 'X-Cart-Token' => @cart.session_token },
         as: :json

    assert_response :success
    @cart.reload
    assert_equal initial_count + 1, @cart.cart_items.count
  end

  test 'merge increases quantity for existing items' do
    existing_item = @cart.cart_items.first
    original_quantity = existing_item.quantity
    items_data = [
      { product_id: existing_item.product_id, size: existing_item.size, quantity: 5 }
    ]

    post merge_api_cart_path,
         params: { items: items_data },
         headers: { 'X-Cart-Token' => @cart.session_token },
         as: :json

    assert_response :success
    existing_item.reload
    assert_equal original_quantity + 5, existing_item.quantity
  end

  test 'clear removes all cart items' do
    assert @cart.cart_items.any?

    delete clear_api_cart_path,
           headers: { 'X-Cart-Token' => @cart.session_token }

    assert_response :success
    @cart.reload
    assert @cart.cart_items.empty?
  end

  test 'clear returns success message' do
    delete clear_api_cart_path,
           headers: { 'X-Cart-Token' => @cart.session_token }

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 'Cart cleared', json_response['message']
    assert_equal [], json_response['items']
  end
end
