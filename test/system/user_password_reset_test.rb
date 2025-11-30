# frozen_string_literal: true

require 'application_system_test_case'

class UserPasswordResetTest < ApplicationSystemTestCase
  def setup
    @user = users(:user_one)
  end

  test 'user can view forgot password page' do
    visit new_user_password_path

    assert_selector 'h2', text: 'Forgot Your Password?'
    assert_selector 'input[name="user[email]"]'
  end

  test 'user can request password reset' do
    visit new_user_password_path

    fill_in 'Email', with: @user.email
    click_button 'Send Reset Instructions'

    assert_current_path new_user_session_path
  end

  test 'password reset shows error for non-existent email' do
    visit new_user_password_path

    fill_in 'Email', with: 'nonexistent@example.com'
    click_button 'Send Reset Instructions'

    assert_selector '#error_explanation'
  end

  test 'forgot password page has link to login' do
    visit new_user_password_path

    assert_selector 'a', text: 'Log in'
    click_link 'Log in'

    assert_current_path new_user_session_path
  end
end
