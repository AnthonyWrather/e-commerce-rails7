# frozen_string_literal: true

require 'test_helper'

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_one)
  end

  test 'should get login page' do
    get new_user_session_path
    assert_response :success
    assert_select 'h2', 'Sign In'
  end

  test 'should login with valid credentials' do
    post user_session_path, params: {
      user: { email: @user.email, password: 'password123' }
    }
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test 'should not login with invalid credentials' do
    post user_session_path, params: {
      user: { email: @user.email, password: 'wrongpassword' }
    }
    assert_response :unprocessable_content
  end

  test 'should not login unconfirmed user' do
    unconfirmed = users(:unconfirmed_user)
    post user_session_path, params: {
      user: { email: unconfirmed.email, password: 'password123' }
    }
    assert_response :redirect
    follow_redirect!
    assert_select 'div', /confirm your email/i
  end

  test 'should logout and create new guest cart token' do
    sign_in @user

    delete destroy_user_session_path

    assert_redirected_to root_path
    assert_not_nil cookies[:cart_token]
  end

  test 'should merge guest cart with user cart on login' do
    product = products(:product_one)
    product_two = products(:product_two)

    user_cart = Cart.create!(session_token: 'user_cart_token', user: @user)
    user_cart.cart_items.create!(product: product, size: '', quantity: 1, price: product.price)

    guest_cart = Cart.create!(session_token: 'guest_cart_token')
    guest_cart.cart_items.create!(product: product_two, size: '', quantity: 3, price: product_two.price)

    cookies[:cart_token] = 'guest_cart_token'

    post user_session_path, params: {
      user: { email: @user.email, password: 'password123' }
    }

    user_cart.reload
    assert_equal 2, user_cart.cart_items.count
    assert_not Cart.exists?(guest_cart.id)
  end

  test 'should merge quantities when same product exists in both carts' do
    product = products(:product_one)

    user_cart = Cart.create!(session_token: 'user_cart_qty', user: @user)
    user_cart.cart_items.create!(product: product, size: 'Medium', quantity: 2, price: product.price)

    guest_cart = Cart.create!(session_token: 'guest_cart_qty')
    guest_cart.cart_items.create!(product: product, size: 'Medium', quantity: 3, price: product.price)

    cookies[:cart_token] = 'guest_cart_qty'

    post user_session_path, params: {
      user: { email: @user.email, password: 'password123' }
    }

    user_cart.reload
    item = user_cart.cart_items.find_by(product: product, size: 'Medium')
    assert_equal 5, item.quantity # 2 + 3
  end

  test 'should not merge empty guest cart' do
    product = products(:product_one)

    user_cart = Cart.create!(session_token: 'user_cart_empty', user: @user)
    user_cart.cart_items.create!(product: product, size: '', quantity: 1, price: product.price)

    empty_guest_cart = Cart.create!(session_token: 'empty_guest_cart')
    cookies[:cart_token] = 'empty_guest_cart'

    post user_session_path, params: {
      user: { email: @user.email, password: 'password123' }
    }

    assert_equal 1, user_cart.reload.cart_items.count
    assert Cart.exists?(empty_guest_cart.id) # Empty cart not destroyed
  end

  test 'should create user cart if none exists' do
    @user.carts.destroy_all

    guest_cart = Cart.create!(session_token: 'guest_for_new_user_cart')
    product = products(:product_one)
    guest_cart.cart_items.create!(product: product, size: '', quantity: 2, price: product.price)

    cookies[:cart_token] = 'guest_for_new_user_cart'

    post user_session_path, params: {
      user: { email: @user.email, password: 'password123' }
    }

    @user.reload
    assert @user.carts.any?
    assert_equal 1, @user.carts.first.cart_items.count
  end

  test 'should show remember me checkbox' do
    get new_user_session_path
    assert_select 'input[type=checkbox][name="user[remember_me]"]'
  end

  test 'should show forgot password link' do
    get new_user_session_path
    assert_select 'a[href=?]', new_user_password_path
  end

  test 'should show sign up link' do
    get new_user_session_path
    assert_select 'a[href=?]', new_user_registration_path
  end
end
