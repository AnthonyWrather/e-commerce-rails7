# frozen_string_literal: true

require 'application_system_test_case'

class AdminPasswordResetTest < ApplicationSystemTestCase
  setup do
    @admin_user = admin_users(:admin_user_one)
  end

  test 'admin sees error with invalid email' do
    visit new_admin_user_password_path

    fill_in 'Email', with: 'nonexistent@example.com'
    click_button 'Send Reset Instructions'

    assert_text 'Email not found'
  end

  test 'admin can reset password with valid token' do
    # Generate reset token
    raw_token, hashed_token = Devise.token_generator.generate(AdminUser, :reset_password_token)
    @admin_user.update!(
      reset_password_token: hashed_token,
      reset_password_sent_at: Time.current
    )

    visit edit_admin_user_password_path(reset_password_token: raw_token)

    assert_selector 'h2', text: 'Change your password'

    fill_in 'New password', with: 'newpassword123'
    fill_in 'Confirm new password', with: 'newpassword123'
    click_button 'Change my password'

    assert_current_path admin_path
  end

  test 'admin cannot reset password with mismatched confirmation' do
    raw_token, hashed_token = Devise.token_generator.generate(AdminUser, :reset_password_token)
    @admin_user.update!(
      reset_password_token: hashed_token,
      reset_password_sent_at: Time.current
    )

    visit edit_admin_user_password_path(reset_password_token: raw_token)

    fill_in 'New password', with: 'newpassword123'
    fill_in 'Confirm new password', with: 'differentpassword'
    click_button 'Change my password'

    assert_text "Password confirmation doesn't match Password"
  end

  test 'admin cannot reset password with expired token' do
    raw_token, hashed_token = Devise.token_generator.generate(AdminUser, :reset_password_token)
    @admin_user.update!(
      reset_password_token: hashed_token,
      reset_password_sent_at: 7.hours.ago # Devise default is 6 hours
    )

    visit edit_admin_user_password_path(reset_password_token: raw_token)

    fill_in 'New password', with: 'newpassword123'
    fill_in 'Confirm new password', with: 'newpassword123'
    click_button 'Change my password'

    assert_text 'Reset password token has expired'
  end

  test 'admin cannot reset password with invalid token' do
    visit edit_admin_user_password_path(reset_password_token: 'invalid_token')

    fill_in 'New password', with: 'newpassword123'
    fill_in 'Confirm new password', with: 'newpassword123'
    click_button 'Change my password'

    assert_text 'Reset password token is invalid'
  end

  test 'admin cannot reset password with too short password' do
    raw_token, hashed_token = Devise.token_generator.generate(AdminUser, :reset_password_token)
    @admin_user.update!(
      reset_password_token: hashed_token,
      reset_password_sent_at: Time.current
    )

    visit edit_admin_user_password_path(reset_password_token: raw_token)

    fill_in 'New password', with: '12345'
    fill_in 'Confirm new password', with: '12345'
    click_button 'Change my password'

    assert_text 'Password is too short (minimum is 6 characters)'
  end
end
