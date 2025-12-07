# Semantic Logger Integration Summary

## Issue: Stream Rails Logs to Honeybadger

**Date**: December 7, 2025  
**Branch**: `copilot/stream-logs-to-honeybadger`  
**Status**: ✅ Complete

## Objective

Implement `rails_semantic_logger` to stream log data to Honeybadger for monitoring and debugging, with environment-based configuration:
- Production: Always stream logs
- Test: Always stream logs
- Development: Only stream if `HONEYBADGER_ENABLED_IN_DEV=true`

## Solution Implemented

### 1. Added rails_semantic_logger Gem

```ruby
gem 'rails_semantic_logger', '~> 4.17'
```

Version installed: v4.18.0

### 2. Created Semantic Logger Initializer

Location: `config/initializers/semantic_logger.rb`

**Features:**
- Configures SemanticLogger with application name 'e-commerce-rails7'
- Sets log level from `RAILS_LOG_LEVEL` environment variable (default: info)
- Adds stdout appender with color formatting for console output
- Integrates with Honeybadger when enabled:
  - Captures logs as breadcrumbs for error context
  - Sends error logs with exceptions as Honeybadger notices
  - Only active in production, test, or development with `HONEYBADGER_ENABLED_IN_DEV=true`

### 3. Updated Production Environment

Modified `config/environments/production.rb` to reference SemanticLogger instead of manually configuring ActiveSupport::Logger.

### 4. Comprehensive Testing

**Unit Tests** (`test/config/semantic_logger_test.rb`):
- 9 tests covering all aspects of configuration
- Tests verify:
  - Initializer existence
  - Application name configuration
  - Environment-based Honeybadger integration
  - Log appenders setup
  - Production environment configuration
  - Logger method availability

**Test Results:**
- Unit Tests: 1114 runs, 2630 assertions, 0 failures
- System Tests: 245 runs, 500 assertions, 0 failures
- Total: 1359 runs, 3130 assertions, 0 failures
- Coverage: 89.99% (unit), 57.43% (system) - Well above 40% requirement

### 5. Code Quality

**RuboCop**: 235 files inspected, 0 offenses detected

### 6. Documentation

Created comprehensive documentation: `documentation/semantic-logger-honeybadger-integration.md`

Contents:
- Overview and configuration
- How it works (stdout logging, breadcrumbs, error reporting)
- Usage examples
- Environment variables
- Testing instructions
- Troubleshooting guide
- Future enhancements

## Technical Implementation

### Log Flow

1. **Application Code** → Uses standard `Rails.logger` methods
2. **SemanticLogger** → Captures logs with structured data
3. **Stdout Appender** → Displays logs in console with color
4. **Honeybadger Integration** (when enabled):
   - Info+ logs → Honeybadger breadcrumbs
   - Error logs with exceptions → Honeybadger error notices

### Environment Configuration

```ruby
honeybadger_enabled = Rails.env.production? ||
                      Rails.env.test? ||
                      (Rails.env.development? && ENV['HONEYBADGER_ENABLED_IN_DEV'] == 'true')
```

### Log Capture Example

```ruby
SemanticLogger.on_log do |log|
  next unless log.level_index >= SemanticLogger::Levels.index(:info)
  
  # Build metadata
  metadata = {
    level: log.level.to_s,
    timestamp: log.time.iso8601,
    tags: log.tags,
    payload: log.payload
  }
  
  # Add breadcrumb to Honeybadger
  Honeybadger.add_breadcrumb(
    log.message || 'Log event',
    metadata: metadata,
    category: 'log'
  )
  
  # Send errors with exceptions to Honeybadger
  if log.exception && log.level_index >= SemanticLogger::Levels.index(:error)
    Honeybadger.notify(log.exception, context: metadata)
  end
end
```

## Benefits

1. **Rich Error Context**: All logs leading up to errors are captured as breadcrumbs
2. **Structured Logging**: Consistent, machine-readable log format
3. **Environment Control**: Easy to enable/disable per environment
4. **No Code Changes Required**: Existing `Rails.logger` calls work unchanged
5. **Performance**: Minimal overhead, non-blocking
6. **Debugging**: Complete context available when investigating production issues

## Usage

### Standard Logging

```ruby
Rails.logger.info "User logged in", user_id: user.id
Rails.logger.error "Payment failed", exception: e, order_id: order.id
```

### Tagged Logging

```ruby
Rails.logger.tagged("OrderProcessing", order_id: order.id) do
  Rails.logger.info "Processing order"
  Rails.logger.info "Order completed"
end
```

### Development Testing

```bash
# Enable Honeybadger in development
HONEYBADGER_ENABLED_IN_DEV=true bin/rails server

# Normal development (no Honeybadger)
bin/rails server
```

## Files Changed

### Added
- `config/initializers/semantic_logger.rb` (69 lines)
- `test/config/semantic_logger_test.rb` (99 lines)
- `documentation/semantic-logger-honeybadger-integration.md` (172 lines)

### Modified
- `Gemfile` - Added rails_semantic_logger gem
- `Gemfile.lock` - Updated dependencies
- `config/environments/production.rb` - Updated logger configuration

**Total Lines Added**: 340 lines  
**Total Lines Modified**: ~10 lines

## Compliance with Requirements

✅ **Implemented rails_semantic_logger**: Gem added and configured  
✅ **Stream to Honeybadger**: Logs streamed as breadcrumbs and error notices  
✅ **Production**: Always streams  
✅ **Test**: Always streams  
✅ **Development**: Only streams with `HONEYBADGER_ENABLED_IN_DEV=true`  
✅ **Tests**: Added unit tests, all passing  
✅ **All tests pass**: bin/rails test (1114/1114 ✓)  
✅ **System tests pass**: bin/rails test:system (245/245 ✓)  
✅ **Coverage**: 89.99%/57.43% (well above 40%)  
✅ **RuboCop**: 0 offenses  
✅ **Documentation**: Comprehensive guide added

## Future Enhancements

Potential improvements for consideration:

1. **Log Sampling**: Implement sampling for high-volume endpoints
2. **Custom Formatters**: Add specific formatters for different log types
3. **Performance Metrics**: Integrate performance logging
4. **Log Aggregation**: Consider additional log aggregation services
5. **Alerting**: Set up Honeybadger alerts for specific log patterns

## Conclusion

The implementation successfully adds structured logging with Honeybadger integration while maintaining backward compatibility and meeting all specified requirements. The solution is well-tested, documented, and ready for production use.
