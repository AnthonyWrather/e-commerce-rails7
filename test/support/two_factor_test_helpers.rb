# frozen_string_literal: true

# Two-factor authentication testing helpers for integration tests.
#
# Usage in tests:
#
#   class TwoFactorTest < ActionDispatch::IntegrationTest
#     include TwoFactorTestHelpers
#
#     test 'should require 2FA for admin with 2FA enabled' do
#       admin = create_admin_with_2fa
#       # test code...
#     end
#   end
#
# Helper Methods:
# - create_admin_with_2fa(email:, password:) - Create an admin user with 2FA enabled
#
module TwoFactorTestHelpers
  # Create an admin user with two-factor authentication enabled.
  # Generates OTP secret and backup codes automatically.
  #
  # @param email [String] admin email (default: auto-generated)
  # @param password [String] admin password (default: 'password123')
  # @return [AdminUser] admin user with 2FA enabled
  #
  # Example:
  #   admin = create_admin_with_2fa
  #   admin = create_admin_with_2fa(email: 'test@example.com', password: 'secure123')
  #
  def create_admin_with_2fa(email: nil, password: 'password123')
    admin = AdminUser.create!(
      email: email || "admin_2fa_#{SecureRandom.hex(4)}@example.com",
      password: password,
      password_confirmation: password
    )
    admin.otp_secret = AdminUser.generate_otp_secret
    admin.otp_required_for_login = true
    admin.generate_otp_backup_codes!
    admin.save!
    admin
  end

  # Generate a valid TOTP code for an admin user with 2FA.
  #
  # @param admin [AdminUser] admin user with OTP secret
  # @return [String] valid 6-digit TOTP code
  #
  # Example:
  #   code = generate_totp_code(admin)
  #   fill_in 'otp_attempt', with: code
  #
  def generate_totp_code(admin)
    ROTP::TOTP.new(admin.otp_secret).now
  end
end
