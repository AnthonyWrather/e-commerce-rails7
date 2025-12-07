# frozen_string_literal: true

# Rails Semantic Logger configuration
# Enhances logging and integrates with Honeybadger for error context
# - Production: Always streams structured logs
# - Test: Always streams structured logs
# - Development: Only streams if HONEYBADGER_ENABLED_IN_DEV=true

# Configure SemanticLogger
SemanticLogger.application = 'e-commerce-rails7'

# Set log level from environment or default to info
log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info').to_sym
SemanticLogger.default_level = log_level

# Add stdout appender for console output with color formatting
SemanticLogger.add_appender(
  io: $stdout,
  level: log_level,
  formatter: :color
)

# Configure Honeybadger breadcrumb logging based on environment
# Breadcrumbs provide context when errors occur
honeybadger_enabled = Rails.env.production? ||
                      Rails.env.test? ||
                      (Rails.env.development? && ENV['HONEYBADGER_ENABLED_IN_DEV'] == 'true')

if honeybadger_enabled && defined?(Honeybadger)
  # Subscribe to semantic logger to capture logs as Honeybadger breadcrumbs
  # This provides rich context when errors are reported
  SemanticLogger.on_log do |log|
    next unless log.level_index >= SemanticLogger::Levels.index(:info)

    # Build breadcrumb metadata
    metadata = {
      level: log.level.to_s,
      timestamp: log.time.iso8601
    }

    # Add tags if present
    metadata[:tags] = log.tags if log.tags.present?
    metadata[:named_tags] = log.named_tags if log.named_tags.present?
    metadata[:payload] = log.payload if log.payload.present?

    # Add to Honeybadger breadcrumbs (provides context for errors)
    Honeybadger.add_breadcrumb(
      log.message || 'Log event',
      metadata: metadata,
      category: 'log'
    )

    # For errors and fatals with exceptions, send as notice to Honeybadger
    # Only send if there's an actual exception (not just an error message)
    if log.exception && log.level_index >= SemanticLogger::Levels.index(:error)
      Honeybadger.notify(
        log.exception,
        context: metadata.merge(
          application: SemanticLogger.application,
          environment: Rails.env
        )
      )
    end
  rescue StandardError => e
    # Don't let logging failures break the application
    warn "Failed to send log to Honeybadger: #{e.message}"
  end
end
