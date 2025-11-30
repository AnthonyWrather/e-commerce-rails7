# frozen_string_literal: true

require 'application_system_test_case'

class AccountSettingsTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    sign_in @user
  end

  # Profile Update Tests
  test 'user can view edit profile page' do
    visit edit_account_path

    assert_selector 'h1', text: 'Edit Profile'
    assert_selector 'h2', text: 'Personal Information'
    assert_selector 'h2', text: 'Email Address'
    assert_selector 'h2', text: 'Change Password'
  end

  test 'user can update their full name' do
    visit edit_account_path

    fill_in 'Full Name', with: 'Updated Name'
    click_button 'Save Changes'

    assert_text 'Profile updated successfully.'
    assert_text 'Updated Name'
  end

  test 'user can update their phone number' do
    visit edit_account_path

    fill_in 'Phone Number', with: '+44 123 456 7890'
    click_button 'Save Changes'

    assert_text 'Profile updated successfully.'
    visit account_path
    assert_text '+44 123 456 7890'
  end

  test 'user cannot update profile with blank name' do
    visit edit_account_path

    fill_in 'Full Name', with: ''
    click_button 'Save Changes'

    assert_text "can't be blank"
  end

  test 'user cannot update profile with name too short' do
    visit edit_account_path

    fill_in 'Full Name', with: 'A'
    click_button 'Save Changes'

    assert_text 'is too short'
  end

  # Email Change Tests
  test 'changing email requires current password' do
    visit edit_account_path

    fill_in 'Email', with: 'newemail@example.com'
    click_button 'Save Changes'

    assert_text 'is incorrect'
  end

  test 'user can update email with correct current password' do
    visit edit_account_path

    fill_in 'Email', with: 'newemail@example.com'
    fill_in 'user_current_password', with: 'password123'
    click_button 'Save Changes'

    assert_text 'Profile updated successfully.'
  end

  # Password Change Tests
  test 'changing password requires current password' do
    visit edit_account_path

    fill_in 'New Password', with: 'newpassword123'
    fill_in 'Confirm New Password', with: 'newpassword123'
    click_button 'Save Changes'

    assert_text 'is incorrect'
  end

  test 'user can change password with correct current password' do
    visit edit_account_path

    fill_in 'New Password', with: 'newpassword123'
    fill_in 'Confirm New Password', with: 'newpassword123'
    fill_in 'user_current_password', with: 'password123'
    click_button 'Save Changes'

    assert_text 'Profile updated successfully.'
  end

  test 'password confirmation must match' do
    visit edit_account_path

    fill_in 'New Password', with: 'newpassword123'
    fill_in 'Confirm New Password', with: 'differentpassword'
    fill_in 'user_current_password', with: 'password123'
    click_button 'Save Changes'

    assert_text "doesn't match"
  end

  # Navigation Tests
  test 'user can cancel and return to dashboard' do
    visit edit_account_path

    click_link 'Cancel'
    assert_selector 'h1', text: 'Account Dashboard'
  end

  test 'user can navigate to edit profile from dashboard edit link' do
    visit account_path

    click_link 'Edit', match: :first
    assert_selector 'h1', text: 'Edit Profile'
  end
end
