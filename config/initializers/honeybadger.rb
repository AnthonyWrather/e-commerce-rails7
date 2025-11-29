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
  end
end
