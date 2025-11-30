# frozen_string_literal: true

# Active Record Encryption configuration for secure data storage
# Used by devise-two-factor gem for OTP secrets

# Generate deterministic keys derived from secret_key_base for encryption
# This ensures the same secret_key_base produces the same encryption keys
require 'openssl'

# Derive encryption keys from Rails secret_key_base
# This is a secure way to generate deterministic encryption keys
secret_base = Rails.application.credentials.secret_key_base || ENV.fetch('SECRET_KEY_BASE', 'development_secret_key')

# Use HKDF (HMAC-based Key Derivation Function) to derive keys
def derive_key(secret, info, length)
  OpenSSL::KDF.hkdf(
    secret,
    salt: 'active_record_encryption',
    info: info,
    length: length,
    hash: 'SHA256'
  )
end

# Set up Active Record encryption configuration
Rails.application.configure do
  config.active_record.encryption.primary_key = derive_key(secret_base, 'primary_key', 32)
  config.active_record.encryption.deterministic_key = derive_key(secret_base, 'deterministic_key', 32)
  config.active_record.encryption.key_derivation_salt = derive_key(secret_base, 'key_derivation_salt', 32)
end
