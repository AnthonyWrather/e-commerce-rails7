# frozen_string_literal: true

require 'application_system_test_case'

class UserRegistrationTest < ApplicationSystemTestCase
  test 'user can view registration page' do
    visit new_user_registration_path

    assert_selector 'h2', text: 'Create Your Account'
    assert_selector 'input[name="user[full_name]"]'
    assert_selector 'input[name="user[email]"]'
    assert_selector 'input[name="user[password]"]'
    assert_selector 'input[name="user[password_confirmation]"]'
  end

  test 'user can register with valid information' do
    visit new_user_registration_path

    fill_in 'Full Name', with: 'Test User'
    fill_in 'Email', with: 'systemtest@example.com'
    fill_in 'Phone', with: '+44 20 1234 5678'
    fill_in 'Password', with: 'password123'
    fill_in 'Confirm Password', with: 'password123'
    click_button 'Sign up'

    assert_current_path new_user_session_path
    assert User.find_by(email: 'systemtest@example.com')
  end

  test 'registration shows validation errors' do
    visit new_user_registration_path

    fill_in 'Full Name', with: ''
    fill_in 'Email', with: 'invalid-email'
    fill_in 'Password', with: 'short'
    fill_in 'Confirm Password', with: 'different'
    click_button 'Sign up'

    assert_selector '#error_explanation'
  end

  test 'registration page has link to login' do
    visit new_user_registration_path

    assert_selector 'a', text: 'Log in'
    click_link 'Log in'

    assert_current_path new_user_session_path
  end
end
