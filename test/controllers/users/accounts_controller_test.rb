# frozen_string_literal: true

require 'test_helper'

class Users::AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test 'should get show (dashboard)' do
    get account_url
    assert_response :success
    assert_select 'h1', 'Account Dashboard'
  end

  test 'should get edit' do
    get edit_account_url
    assert_response :success
    assert_select 'h1', 'Edit Profile'
  end

  test 'should require authentication for account' do
    sign_out @user
    # Since routes are wrapped in authenticated :user block,
    # unauthenticated requests get 404
    get '/account'
    assert_response :not_found
  end

  test 'should update profile without password change' do
    patch account_url, params: {
      user: {
        full_name: 'Updated Name',
        phone: '+44 20 1111 2222'
      }
    }
    assert_redirected_to account_url
    @user.reload
    assert_equal 'Updated Name', @user.full_name
    assert_equal '+44 20 1111 2222', @user.phone
  end

  test 'should require current password to change email' do
    patch account_url, params: {
      user: {
        email: 'newemail@example.com',
        current_password: 'wrongpassword'
      }
    }
    assert_response :unprocessable_content
    @user.reload
    assert_equal 'user1@example.com', @user.email
  end

  test 'should update email with correct current password' do
    patch account_url, params: {
      user: {
        email: 'newemail@example.com',
        current_password: 'password123'
      }
    }
    assert_redirected_to account_url
    @user.reload
    # With confirmable, email goes to unconfirmed_email first
    assert_equal 'newemail@example.com', @user.unconfirmed_email
  end

  test 'should update password with correct current password' do
    patch account_url, params: {
      user: {
        password: 'newpassword123',
        password_confirmation: 'newpassword123',
        current_password: 'password123'
      }
    }
    assert_redirected_to account_url
    @user.reload
    assert @user.valid_password?('newpassword123')
  end

  test 'should not update password with incorrect current password' do
    patch account_url, params: {
      user: {
        password: 'newpassword123',
        password_confirmation: 'newpassword123',
        current_password: 'wrongpassword'
      }
    }
    assert_response :unprocessable_content
    @user.reload
    assert @user.valid_password?('password123')
  end

  test 'should fail validation for invalid full_name' do
    patch account_url, params: {
      user: {
        full_name: ''
      }
    }
    assert_response :unprocessable_content
    @user.reload
    assert_equal 'John Smith', @user.full_name
  end

  test 'should display recent orders on dashboard' do
    # Create an order for the user
    Order.create!(
      user: @user,
      customer_email: @user.email,
      name: 'John Smith',
      address: '123 Test St',
      total: 10_000,
      fulfilled: false
    )

    get account_url
    assert_response :success
    assert_select 'table tbody tr', minimum: 1
  end

  test 'should display primary address on dashboard' do
    get account_url
    assert_response :success
    assert_match 'Primary Address', response.body
  end
end
