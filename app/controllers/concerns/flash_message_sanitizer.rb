# frozen_string_literal: true

# Concern to prevent ActionDispatch::Cookies::CookieOverflow errors
# by sanitizing flash messages to stay within cookie size limits.
#
# The session cookie has a 4KB (4096 bytes) limit. Flash messages are stored
# in the session, so large flash messages can cause CookieOverflow errors.
# This concern truncates individual flash messages and limits the total
# number of messages to prevent overflow.
module FlashMessageSanitizer
  extend ActiveSupport::Concern

  # Maximum size for a single flash message (in characters)
  # Accounting for encoding overhead, we use a conservative limit
  MAX_MESSAGE_SIZE = 500

  # Maximum number of error items to show when there are many errors
  MAX_ERROR_ITEMS = 5

  # Suffix to indicate message was truncated
  TRUNCATION_SUFFIX = '... (message truncated)'

  included do
    after_action :sanitize_flash_messages
  end

  private

  # Sanitizes all flash messages to prevent cookie overflow
  def sanitize_flash_messages
    return if flash.empty?

    flash.each do |key, value|
      flash[key] = sanitize_message(value)
    end
  end

  # Sanitizes a single message, truncating if necessary
  def sanitize_message(message)
    return message unless message.is_a?(String)
    return message if message.length <= MAX_MESSAGE_SIZE

    truncate_message(message)
  end

  # Truncates a message to the maximum allowed size
  def truncate_message(message)
    truncated = message[0, MAX_MESSAGE_SIZE - TRUNCATION_SUFFIX.length]
    # Try to truncate at a word boundary for readability
    last_space = truncated.rindex(/\s/)
    truncated = truncated[0, last_space] if last_space && last_space > MAX_MESSAGE_SIZE / 2
    "#{truncated}#{TRUNCATION_SUFFIX}"
  end

  # Helper method to format multiple errors for flash messages
  # Use this in controllers when displaying multiple errors
  def format_errors_for_flash(errors, prefix: nil)
    return '' if errors.blank?

    error_messages = extract_error_messages(errors)
    formatted = limit_error_messages(error_messages)

    prefix.present? ? "#{prefix}: #{formatted}" : formatted
  end

  # Extracts error messages from various error formats
  def extract_error_messages(errors)
    case errors
    when Array
      errors.map { |e| format_single_error(e) }
    when Hash
      errors.map { |k, v| "#{k}: #{v}" }
    when ActiveModel::Errors
      errors.full_messages
    else
      [errors.to_s]
    end
  end

  # Formats a single error item
  def format_single_error(error)
    case error
    when Hash
      if error[:table] && error[:error]
        "#{error[:table]}: #{truncate_error_detail(error[:error])}"
      else
        error.values.join(': ')
      end
    else
      error.to_s
    end
  end

  # Truncates error detail to keep individual errors reasonable
  def truncate_error_detail(detail)
    max_detail = 100
    return detail if detail.to_s.length <= max_detail

    "#{detail.to_s[0, max_detail - 3]}..."
  end

  # Limits the number of error messages shown
  def limit_error_messages(messages)
    return messages.first if messages.size == 1

    if messages.size <= MAX_ERROR_ITEMS
      messages.join('; ')
    else
      shown = messages.first(MAX_ERROR_ITEMS)
      remaining = messages.size - MAX_ERROR_ITEMS
      "#{shown.join('; ')} (and #{remaining} more error#{'s' if remaining > 1})"
    end
  end
end
