# frozen_string_literal: true

require 'application_system_test_case'

class UserLoginTest < ApplicationSystemTestCase
  def setup
    @user = users(:user_one)
  end

  test 'user can view login page' do
    visit new_user_session_path

    assert_selector 'h2', text: 'Sign In'
    assert_selector 'input[name="user[email]"]'
    assert_selector 'input[name="user[password]"]'
  end

  test 'user can login with valid credentials' do
    visit new_user_session_path

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    assert_current_path root_path
  end

  test 'login fails with invalid credentials' do
    visit new_user_session_path

    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'wrongpassword'
    click_button 'Log in'

    assert_selector 'div', text: /Invalid Email or password/i
  end

  test 'login shows remember me checkbox' do
    visit new_user_session_path

    assert_selector 'input[type=checkbox][name="user[remember_me]"]'
  end

  test 'login page has link to registration' do
    visit new_user_session_path

    assert_selector 'a', text: 'Sign up'
    click_link 'Sign up'

    assert_current_path new_user_registration_path
  end

  test 'login page has link to forgot password' do
    visit new_user_session_path

    assert_selector 'a', text: 'Forgot your password?'
    click_link 'Forgot your password?'

    assert_current_path new_user_password_path
  end

  test 'user can logout' do
    visit new_user_session_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    assert_current_path root_path
  end
end
