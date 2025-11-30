# frozen_string_literal: true

require 'test_helper'

class AdminUsers::TwoFactorControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = admin_users(:admin_user_one)
  end

  # GET /admin_users/two_factor/new tests

  test 'should redirect to sign in when not authenticated' do
    get new_admin_users_two_factor_path
    assert_redirected_to new_admin_user_session_path
  end

  test 'should get new when authenticated and 2FA not enabled' do
    sign_in @admin_user
    get new_admin_users_two_factor_path
    assert_response :success
    assert_select 'h2', 'Set Up Two-Factor Authentication'
  end

  test 'should redirect to admin root when 2FA already enabled' do
    admin_with_2fa = create_admin_with_2fa
    sign_in admin_with_2fa
    get new_admin_users_two_factor_path
    assert_redirected_to admin_root_path
  end

  test 'new should generate otp_secret if not already present' do
    sign_in @admin_user
    assert_nil @admin_user.otp_secret

    get new_admin_users_two_factor_path
    assert_response :success
    @admin_user.reload
    assert @admin_user.otp_secret.present?
  end

  test 'new should display QR code' do
    sign_in @admin_user
    get new_admin_users_two_factor_path
    assert_response :success
    assert_match(/<svg/, response.body)
  end

  # POST /admin_users/two_factor tests

  test 'create should enable 2FA with valid code' do
    sign_in @admin_user
    @admin_user.setup_two_factor!
    valid_code = ROTP::TOTP.new(@admin_user.otp_secret).now

    post admin_users_two_factor_path, params: { otp_attempt: valid_code }

    @admin_user.reload
    assert @admin_user.two_factor_enabled?
    assert @admin_user.otp_backup_codes.present?
    assert_response :success
    assert_match(/backup/i, response.body)
  end

  test 'create should fail with invalid code' do
    sign_in @admin_user
    @admin_user.setup_two_factor!

    post admin_users_two_factor_path, params: { otp_attempt: '000000' }

    @admin_user.reload
    assert_not @admin_user.two_factor_enabled?
    assert_response :unprocessable_entity
  end

  # GET /admin_users/two_factor/edit tests

  test 'edit should redirect if 2FA not enabled' do
    sign_in @admin_user
    get edit_admin_users_two_factor_path
    assert_redirected_to new_admin_users_two_factor_path
  end

  test 'edit should display settings when 2FA enabled' do
    admin_with_2fa = create_admin_with_2fa
    sign_in admin_with_2fa
    get edit_admin_users_two_factor_path
    assert_response :success
    assert_select 'h2', 'Two-Factor Authentication Settings'
  end

  # DELETE /admin_users/two_factor tests

  test 'destroy should disable 2FA with correct password' do
    admin_with_2fa = create_admin_with_2fa
    sign_in admin_with_2fa
    delete admin_users_two_factor_path, params: { password: 'password123' }

    admin_with_2fa.reload
    assert_not admin_with_2fa.two_factor_enabled?
    assert_redirected_to admin_root_path
  end

  test 'destroy should fail with incorrect password' do
    admin_with_2fa = create_admin_with_2fa
    sign_in admin_with_2fa
    delete admin_users_two_factor_path, params: { password: 'wrongpassword' }

    admin_with_2fa.reload
    assert admin_with_2fa.two_factor_enabled?
    assert_response :unprocessable_entity
  end

  # POST /admin_users/two_factor/regenerate_backup_codes tests

  test 'regenerate_backup_codes should create new codes' do
    admin_with_2fa = create_admin_with_2fa
    sign_in admin_with_2fa
    old_codes = admin_with_2fa.otp_backup_codes.dup

    post regenerate_backup_codes_admin_users_two_factor_path

    admin_with_2fa.reload
    assert_response :success
    assert_not_equal old_codes, admin_with_2fa.otp_backup_codes
  end

  test 'regenerate_backup_codes should redirect if 2FA not enabled' do
    sign_in @admin_user
    post regenerate_backup_codes_admin_users_two_factor_path
    assert_redirected_to new_admin_users_two_factor_path
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
