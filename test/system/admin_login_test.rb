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

  test 'admin can log out successfully' do
    # Sign in using Devise helper
    sign_in_admin

    # Visit admin dashboard
    visit admin_path

    # Verify we're logged in (admin dashboard shows)
    assert_selector 'h1', text: 'Monthly Revenue'

    # Click the Sign out button
    click_button 'Sign out'

    # Should redirect to root path (default Devise behavior)
    assert_current_path root_path

    # Verify we're logged out by trying to access admin area
    visit admin_path

    # Should be redirected to login page when not authenticated
    assert_current_path new_admin_user_session_path
  end
end
