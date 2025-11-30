# frozen_string_literal: true

require 'test_helper'

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user_params = {
      user: {
        full_name: 'Test User',
        email: 'newuser@example.com',
        phone: '+44 20 1111 2222',
        password: 'password123',
        password_confirmation: 'password123'
      }
    }
  end

  test 'should get new registration page' do
    get new_user_registration_path
    assert_response :success
    assert_select 'h2', 'Create Your Account'
  end

  test 'should create user with valid params' do
    assert_difference 'User.count', 1 do
      post user_registration_path, params: @user_params
    end
    assert_redirected_to new_user_session_path
    user = User.find_by(email: 'newuser@example.com')
    assert_not_nil user
    assert_equal 'Test User', user.full_name
  end

  test 'should not create user without full_name' do
    @user_params[:user][:full_name] = ''
    assert_no_difference 'User.count' do
      post user_registration_path, params: @user_params
    end
    assert_response :unprocessable_content
  end

  test 'should not create user without email' do
    @user_params[:user][:email] = ''
    assert_no_difference 'User.count' do
      post user_registration_path, params: @user_params
    end
    assert_response :unprocessable_content
  end

  test 'should not create user with duplicate email' do
    User.create!(
      full_name: 'Existing User',
      email: 'newuser@example.com',
      password: 'password123',
      confirmed_at: Time.current
    )

    assert_no_difference 'User.count' do
      post user_registration_path, params: @user_params
    end
    assert_response :unprocessable_content
  end

  test 'should transfer guest cart to new user on registration' do
    guest_cart = Cart.create!(session_token: 'guest_token_123')
    product = products(:product_one)
    guest_cart.cart_items.create!(product: product, size: '', quantity: 2, price: product.price)

    cookies[:cart_token] = 'guest_token_123'

    assert_difference 'User.count', 1 do
      post user_registration_path, params: @user_params
    end

    user = User.find_by(email: 'newuser@example.com')
    guest_cart.reload
    assert_equal user, guest_cart.user
  end

  test 'should clear cart_token cookie after successful registration' do
    Cart.create!(session_token: 'guest_token_clear')
    cookies[:cart_token] = 'guest_token_clear'

    post user_registration_path, params: @user_params

    assert_empty cookies[:cart_token].to_s
  end

  test 'registration creates unconfirmed user' do
    post user_registration_path, params: @user_params

    user = User.find_by(email: 'newuser@example.com')
    assert_not_nil user
    assert_not user.confirmed?
  end

  test 'should show minimum password length hint' do
    get new_user_registration_path
    assert_select 'span.text-gray-500', /6 characters minimum/
  end

  test 'should show sign in and forgot password links' do
    get new_user_registration_path
    assert_select 'a[href=?]', new_user_session_path
  end
end
