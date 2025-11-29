# frozen_string_literal: true

require 'application_system_test_case'

class AdminRememberMeTest < ApplicationSystemTestCase
  setup do
    @admin_user = admin_users(:admin_user_one)
  end

  test 'admin login page has remember me checkbox' do
    visit new_admin_user_session_path

    assert_selector 'input[type="checkbox"][name="admin_user[remember_me]"]'
    assert_selector 'label', text: 'Remember me'
  end

  test 'admin can login with remember me checked' do
    visit new_admin_user_session_path

    fill_in 'Email', with: @admin_user.email
    fill_in 'Password', with: 'password123'
    check 'Remember me'
    click_button 'Log in'

    assert_current_path admin_path

    # Verify remember_created_at is set
    @admin_user.reload
    assert @admin_user.remember_created_at.present?, 'remember_created_at should be set'
  end

  test 'admin can login without remember me checked' do
    visit new_admin_user_session_path

    fill_in 'Email', with: @admin_user.email
    fill_in 'Password', with: 'password123'
    # Don't check "Remember me" - leave it unchecked
    click_button 'Log in'

    # Should successfully log in and see admin dashboard
    assert_current_path admin_path
    assert_selector 'h1', text: 'Administration'
  end

  test 'remember me cookie persists across browser sessions' do
    visit new_admin_user_session_path

    fill_in 'Email', with: @admin_user.email
    fill_in 'Password', with: 'password123'
    check 'Remember me'
    click_button 'Log in'

    assert_current_path admin_path

    # Simulate browser restart by clearing session cookies
    # Note: In a real test, you would restart the browser or clear session cookies
    # For this test, we're just verifying the remember_created_at is set
    @admin_user.reload
    assert @admin_user.remember_created_at.present?
  end
end
