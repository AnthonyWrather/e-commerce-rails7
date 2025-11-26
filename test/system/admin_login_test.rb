# frozen_string_literal: true

require 'application_system_test_case'

class AdminLoginTest < ApplicationSystemTestCase
  test 'admin can visit login page' do
    visit new_admin_user_session_path

    assert_selector 'h2', text: 'Admin Login'
    assert_selector 'input[type=email]'
    assert_selector 'input[type=password]'
    assert_selector 'input[type=submit]'
  end

  test 'admin can log in with valid credentials' do
    visit new_admin_user_session_path

    fill_in 'Email', with: 'admin1@example.com'
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    # Should redirect to admin dashboard
    assert_current_path admin_path
  end

  test 'admin cannot log in with invalid credentials' do
    visit new_admin_user_session_path

    fill_in 'Email', with: 'admin1@example.com'
    fill_in 'Password', with: 'wrongpassword'
    click_button 'Log in'

    # Should show error message
    assert_selector '.bg-red-100', text: 'Invalid'
  end
end
