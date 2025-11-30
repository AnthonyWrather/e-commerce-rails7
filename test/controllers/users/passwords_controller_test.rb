# frozen_string_literal: true

require 'test_helper'

class Users::PasswordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = users(:user_one)
  end

  test 'should get forgot password page' do
    get new_user_password_path
    assert_response :success
    assert_select 'h2', 'Forgot Your Password?'
  end

  test 'should send password reset email for existing user' do
    assert_emails 1 do
      post user_password_path, params: {
        user: { email: @user.email }
      }
    end
    assert_redirected_to new_user_session_path
  end

  test 'should not send password reset for non-existent email' do
    assert_emails 0 do
      post user_password_path, params: {
        user: { email: 'nonexistent@example.com' }
      }
    end
    assert_response :unprocessable_content
  end

  test 'should get reset password page with valid token' do
    @user.send_reset_password_instructions
    token = @user.reset_password_token

    get edit_user_password_path(reset_password_token: token)
    assert_response :success
    assert_select 'h2', 'Reset Your Password'
  end

  test 'should reset password with valid token' do
    raw_token, enc_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.update!(reset_password_token: enc_token, reset_password_sent_at: Time.current)

    put user_password_path, params: {
      user: {
        reset_password_token: raw_token,
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
    }

    assert_redirected_to new_user_session_path
    @user.reload
    assert @user.valid_password?('newpassword123')
  end

  test 'should not reset password with invalid token' do
    put user_password_path, params: {
      user: {
        reset_password_token: 'invalidtoken',
        password: 'newpassword123',
        password_confirmation: 'newpassword123'
      }
    }

    assert_response :unprocessable_content
    @user.reload
    assert_not @user.valid_password?('newpassword123')
  end

  test 'should not reset password when confirmation does not match' do
    raw_token, enc_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.update!(reset_password_token: enc_token, reset_password_sent_at: Time.current)

    put user_password_path, params: {
      user: {
        reset_password_token: raw_token,
        password: 'newpassword123',
        password_confirmation: 'differentpassword'
      }
    }

    assert_response :unprocessable_content
    @user.reload
    assert_not @user.valid_password?('newpassword123')
  end

  test 'should show login link on forgot password page' do
    get new_user_password_path
    assert_select 'a[href=?]', new_user_session_path
  end

  test 'should show minimum password length on reset page' do
    raw_token, enc_token = Devise.token_generator.generate(User, :reset_password_token)
    @user.update!(reset_password_token: enc_token, reset_password_sent_at: Time.current)

    get edit_user_password_path(reset_password_token: raw_token)
    assert_select 'span.text-gray-500', /6 characters minimum/
  end
end
