# frozen_string_literal: true

class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :two_factor_authenticatable, :two_factor_backupable,
         :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         otp_secret_encryption_key: ENV.fetch('OTP_SECRET_ENCRYPTION_KEY',
                                              Rails.application.credentials.secret_key_base)

  # Serialization for backup codes stored as JSON array
  serialize :otp_backup_codes, coder: JSON

  # Number of backup codes to generate
  BACKUP_CODES_COUNT = 10

  # Generate a new OTP secret for the user
  def setup_two_factor!
    self.otp_secret = AdminUser.generate_otp_secret
    save!
  end

  # Enable 2FA with the provided OTP code
  def enable_two_factor!(otp_attempt)
    return false unless validate_and_consume_otp!(otp_attempt)

    self.otp_required_for_login = true
    generate_otp_backup_codes!
    save!
    true
  end

  # Disable 2FA after verifying password
  def disable_two_factor!(password)
    return false unless valid_password?(password)

    self.otp_required_for_login = false
    self.otp_secret = nil
    self.consumed_timestep = nil
    self.otp_backup_codes = nil
    save!
    true
  end

  # Check if 2FA is enabled
  def two_factor_enabled?
    otp_required_for_login?
  end

  # Check if 2FA is pending setup (secret generated but not yet enabled)
  def two_factor_pending?
    otp_secret.present? && !otp_required_for_login?
  end

  # Generate new backup codes and save them
  def regenerate_backup_codes!
    generate_otp_backup_codes!
    save!
  end

  # Validate backup code and consume it if valid
  def validate_backup_code(code)
    return false if otp_backup_codes.blank? || code.blank?

    normalized_code = code.to_s.gsub(/[^a-z0-9]/i, '').upcase
    codes = otp_backup_codes.dup

    if (index = codes.find_index { |c| c.gsub(/[^a-z0-9]/i, '').upcase == normalized_code })
      codes.delete_at(index)
      update!(otp_backup_codes: codes)
      true
    else
      false
    end
  end

  # Generate the provisioning URI for QR codes
  def otp_provisioning_uri
    otp_issuer = 'Southcoast Fibreglass Supplies Admin'
    label = "#{otp_issuer}:#{email}"
    ROTP::TOTP.new(otp_secret, issuer: otp_issuer).provisioning_uri(label)
  end
end
