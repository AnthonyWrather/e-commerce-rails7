# Semantic Logger and Honeybadger Integration

## Overview

This document describes the integration of `rails_semantic_logger` gem with Honeybadger for structured logging and log streaming.

## Configuration

### Gem Installation

The `rails_semantic_logger` gem is added to the Gemfile:

```ruby
gem 'rails_semantic_logger', '~> 4.17'
```

### Initializer

The configuration is located in `config/initializers/semantic_logger.rb`.

### Key Features

1. **Structured Logging**: SemanticLogger provides structured, tagged logging throughout the application
2. **Environment-Based Configuration**: 
   - **Production**: Logging always enabled, integrated with Honeybadger
   - **Test**: Logging always enabled, integrated with Honeybadger
   - **Development**: Logging enabled only if `HONEYBADGER_ENABLED_IN_DEV=true` environment variable is set

3. **Honeybadger Integration**:
   - All info-level and above logs are captured as Honeybadger breadcrumbs
   - Error logs with exceptions are sent as Honeybadger error notices
   - Provides rich context when errors occur

## How It Works

### Stdout Logging

All logs are sent to stdout with color formatting for easy reading during development:

```ruby
SemanticLogger.add_appender(
  io: $stdout,
  level: log_level,
  formatter: :color
)
```

### Honeybadger Breadcrumbs

Logs are captured as breadcrumbs in Honeybadger, providing context when errors occur:

```ruby
Honeybadger.add_breadcrumb(
  log.message || 'Log event',
  metadata: metadata,
  category: 'log'
)
```

### Error Reporting

When an error log with an exception is created, it's automatically sent to Honeybadger:

```ruby
if log.exception && log.level_index >= SemanticLogger::Levels.index(:error)
  Honeybadger.notify(log.exception, context: metadata)
end
```

## Usage

### Basic Logging

```ruby
# Info level logging
Rails.logger.info "User logged in", user_id: user.id

# Warning level logging
Rails.logger.warn "Rate limit approaching", current: 90, limit: 100

# Error level logging with exception
Rails.logger.error "Payment failed", exception: e, order_id: order.id
```

### Tagged Logging

```ruby
Rails.logger.tagged("OrderProcessing", order_id: order.id) do
  Rails.logger.info "Processing order"
  # ... order processing logic ...
  Rails.logger.info "Order completed"
end
```

## Environment Variables

### RAILS_LOG_LEVEL

Set the log level for the application:

```bash
RAILS_LOG_LEVEL=debug bin/rails server
```

### HONEYBADGER_ENABLED_IN_DEV

Enable Honeybadger logging in development:

```bash
HONEYBADGER_ENABLED_IN_DEV=true bin/rails server
```

## Testing

### Unit Tests

Tests are located in `test/config/semantic_logger_test.rb`:

```bash
bin/rails test test/config/semantic_logger_test.rb
```

### Verification

To verify that logs are being streamed to Honeybadger:

1. Ensure `HONEYBADGER_API_KEY` is set in credentials or environment
2. Trigger an error in the application
3. Check Honeybadger dashboard for the error with breadcrumb context

## Benefits

1. **Rich Context**: All logs leading up to an error are available as breadcrumbs
2. **Structured Data**: Logs include structured metadata for better analysis
3. **Performance**: Efficient log streaming without impacting application performance
4. **Environment Control**: Easily control log streaming per environment

## Migration from Standard Rails Logger

The integration is transparent - existing `Rails.logger` calls continue to work without modification. The semantic logger replaces the standard Rails logger automatically.

## Troubleshooting

### Logs Not Appearing in Honeybadger

1. Check that `HONEYBADGER_API_KEY` is configured
2. Verify the environment setting (production/test/dev with flag)
3. Check network connectivity to Honeybadger API
4. Review Honeybadger configuration in `config/honeybadger.yml`

### Too Many Logs Sent to Honeybadger

The current configuration only sends info+ logs as breadcrumbs and error+ logs with exceptions as notices. To reduce:

1. Increase the log level in `config/initializers/semantic_logger.rb`
2. Add filters for specific log patterns
3. Adjust the Honeybadger notification threshold

## Future Enhancements

Potential improvements:

1. Add custom log formatters for specific log types
2. Implement log sampling for high-volume endpoints
3. Add performance metrics logging
4. Integrate with additional monitoring tools

## References

- [rails_semantic_logger gem](https://github.com/reidmorrison/rails_semantic_logger)
- [SemanticLogger documentation](http://rocketjob.github.io/semantic_logger/)
- [Honeybadger Ruby documentation](https://docs.honeybadger.io/lib/ruby/)
