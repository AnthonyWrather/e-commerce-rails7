# frozen_string_literal: true

require 'test_helper'

class AdminUsers::TwoFactorVerificationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = admin_users(:admin_user_one)
  end

  # GET /admin_users/two_factor_verification/new tests

  test 'should redirect to sign in when no pending verification' do
    get new_admin_users_two_factor_verification_path
    assert_redirected_to new_admin_user_session_path
  end

  test 'should show verification form when verification pending' do
    admin_with_2fa = create_admin_with_2fa
    # Simulate the state after successful password login with 2FA
    post admin_user_session_path, params: {
      admin_user: { email: admin_with_2fa.email, password: 'password123' }
    }

    # Should be redirected to 2FA verification
    assert_redirected_to new_admin_users_two_factor_verification_path
    follow_redirect!
    assert_response :success
    assert_select 'h2', 'Two-Factor Verification'
  end

  # POST /admin_users/two_factor_verification tests

  test 'should sign in with valid OTP code' do
    admin_with_2fa = create_admin_with_2fa
    # First, trigger the 2FA flow
    post admin_user_session_path, params: {
      admin_user: { email: admin_with_2fa.email, password: 'password123' }
    }
    follow_redirect!

    # Now submit valid OTP
    valid_code = ROTP::TOTP.new(admin_with_2fa.otp_secret).now
    post admin_users_two_factor_verification_path, params: { otp_attempt: valid_code }

    assert_redirected_to admin_root_path
  end

  test 'should fail with invalid OTP code' do
    admin_with_2fa = create_admin_with_2fa
    # First, trigger the 2FA flow
    post admin_user_session_path, params: {
      admin_user: { email: admin_with_2fa.email, password: 'password123' }
    }
    follow_redirect!

    post admin_users_two_factor_verification_path, params: { otp_attempt: '000000' }

    assert_response :unprocessable_entity
  end

  test 'should sign in with valid backup code' do
    admin_with_2fa = create_admin_with_2fa
    backup_code = admin_with_2fa.otp_backup_codes.first
    # First, trigger the 2FA flow
    post admin_user_session_path, params: {
      admin_user: { email: admin_with_2fa.email, password: 'password123' }
    }
    follow_redirect!

    # Use a backup code
    post admin_users_two_factor_verification_path, params: { otp_attempt: backup_code }

    assert_redirected_to admin_root_path
    follow_redirect!
    assert_match(/backup code/i, flash[:notice])
  end

  test 'should consume backup code after use' do
    admin_with_2fa = create_admin_with_2fa
    backup_code = admin_with_2fa.otp_backup_codes.second
    original_count = admin_with_2fa.otp_backup_codes.count
    # First, trigger the 2FA flow
    post admin_user_session_path, params: {
      admin_user: { email: admin_with_2fa.email, password: 'password123' }
    }
    follow_redirect!

    post admin_users_two_factor_verification_path, params: { otp_attempt: backup_code }

    admin_with_2fa.reload
    assert_equal original_count - 1, admin_with_2fa.otp_backup_codes.count
  end

  test 'should redirect to sign in when session expires' do
    # Don't set up session, just try to verify
    post admin_users_two_factor_verification_path, params: { otp_attempt: '123456' }

    assert_redirected_to new_admin_user_session_path
  end

  private

  def create_admin_with_2fa
    admin = AdminUser.create!(
      email: "admin_2fa_#{SecureRandom.hex(4)}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )
    admin.otp_secret = AdminUser.generate_otp_secret
    admin.otp_required_for_login = true
    admin.generate_otp_backup_codes!
    admin.save!
    admin
  end
end
