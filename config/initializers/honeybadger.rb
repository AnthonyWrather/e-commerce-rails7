# frozen_string_literal: true

# Honeybadger configuration initializer
# Main configuration is in config/honeybadger.yml
# This file contains runtime configuration that can't be in YAML

Honeybadger.configure do |config|
  # Add request ID to all error reports for correlation
  config.before_notify do |notice|
    if defined?(Current) && Current.respond_to?(:request_id)
      notice.context[:request_id] = Current.request_id
    end

    # Add environment information
    notice.context[:rails_env] = Rails.env
    notice.context[:hostname] = begin
      Socket.gethostname
    rescue StandardError
      'unknown'
    end

    # Add timestamp
    notice.context[:error_timestamp] = Time.current.iso8601
  end

  # Configure backend based on environment
  # Development: Requires HONEYBADGER_ENABLED_IN_DEV=true to use 'server' backend
  # Test: Requires HONEYBADGER_ENABLED_IN_TEST=true to use 'server' backend
  # Production: Always use 'server' backend
  if (Rails.env.development? && ENV['HONEYBADGER_ENABLED_IN_DEV'] != 'true') ||
     (Rails.env.test? && ENV['HONEYBADGER_ENABLED_IN_TEST'] != 'true')
    config.backend = 'null'
  else
    config.backend = 'server'
  end

  # Add custom error grouping
  config.before_notify do |notice|
    # Group test errors separately
    if notice.error_message&.include?('Test') && notice.error_message.include?('Honeybadger')
      notice.fingerprint = "test-error-#{notice.error_class}"
    end
  end
end
