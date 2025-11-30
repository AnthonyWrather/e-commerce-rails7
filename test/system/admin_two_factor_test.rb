# frozen_string_literal: true

require 'application_system_test_case'

class AdminTwoFactorTest < ApplicationSystemTestCase
  setup do
    @admin = admin_users(:admin_user_one)
  end

  test 'admin can view 2FA setup page' do
    sign_in @admin
    visit new_admin_users_two_factor_path

    assert_selector 'h2', text: 'Set Up Two-Factor Authentication'
    assert_selector 'svg' # QR code
    assert_selector 'input[name=otp_attempt]'
  end

  test 'admin can enable 2FA with valid code' do
    sign_in @admin
    visit new_admin_users_two_factor_path

    # Wait for the QR code to be generated and get the OTP secret
    @admin.reload
    assert @admin.otp_secret.present?

    # Generate valid TOTP code
    valid_code = generate_totp_code(@admin)

    fill_in 'otp_attempt', with: valid_code
    click_button 'Verify and Enable 2FA'

    # Should show backup codes page
    assert_selector 'h2', text: 'Save Your Backup Codes'
    assert_selector '.font-mono' # Backup codes display
  end

  test 'admin sees 2FA settings link when enabled' do
    admin_with_2fa = create_admin_with_2fa(email: 'admin_2fa_system@example.com')

    # Sign in with 2FA
    visit new_admin_user_session_path
    fill_in 'Email', with: admin_with_2fa.email
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    # Should be on 2FA verification page
    assert_selector 'h2', text: 'Two-Factor Verification'

    # Enter valid OTP
    fill_in 'otp_attempt', with: generate_totp_code(admin_with_2fa)
    click_button 'Verify'

    # Now on admin dashboard, check for 2FA settings link
    assert_selector 'a', text: '2FA Settings'
  end

  test 'admin can view 2FA management page' do
    admin_with_2fa = create_admin_with_2fa(email: 'admin_2fa_manage@example.com')

    sign_in admin_with_2fa
    visit edit_admin_users_two_factor_path

    assert_selector 'h2', text: 'Two-Factor Authentication Settings'
    assert_selector 'button', text: 'Generate New Backup Codes'
    assert_selector 'input[type=submit][value="Disable 2FA"]'
  end

  test 'admin sees enable 2FA link when not enabled' do
    sign_in @admin
    visit admin_path

    assert_selector 'a', text: 'Enable 2FA'
  end

  test 'invalid OTP shows error on 2FA setup' do
    sign_in @admin
    visit new_admin_users_two_factor_path

    fill_in 'otp_attempt', with: '000000'
    click_button 'Verify and Enable 2FA'

    assert_selector '.bg-red-100', text: 'Invalid'
  end

  test 'admin can use backup code to sign in' do
    admin_with_2fa = create_admin_with_2fa(email: 'admin_2fa_backup@example.com')
    backup_code = admin_with_2fa.otp_backup_codes.first

    visit new_admin_user_session_path
    fill_in 'Email', with: admin_with_2fa.email
    fill_in 'Password', with: 'password123'
    click_button 'Log in'

    # Should be on 2FA verification page
    assert_selector 'h2', text: 'Two-Factor Verification'

    # Use the backup code option
    find('summary', text: 'Use a backup code instead').click
    within('details') do
      fill_in 'otp_attempt', with: backup_code
      click_button 'Use Backup Code'
    end

    # Should be redirected to admin dashboard
    assert_current_path admin_path
  end
end
