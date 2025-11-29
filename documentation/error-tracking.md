# Error Tracking with Honeybadger

This document describes how error tracking is configured in this application using Honeybadger.

## Overview

Honeybadger is used for error tracking and monitoring in production. It captures both server-side Ruby errors and client-side JavaScript errors.

## Configuration

### API Key Setup

The Honeybadger API key should be configured via:

1. **Environment Variable** (recommended for production):
   ```bash
   export HONEYBADGER_API_KEY=your_api_key_here
   ```

2. **Rails Credentials** (alternative):
   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```
   Add:
   ```yaml
   honeybadger:
     api_key: your_api_key_here
   ```

### Configuration Files

- `config/honeybadger.yml` - Main configuration file
- `config/initializers/honeybadger.rb` - Runtime configuration

## Features

### Server-Side Error Tracking

- All unhandled exceptions are automatically reported
- User context (user_id, email) is attached to errors via `ApplicationController`
- Sensitive data (passwords, credit cards, etc.) is automatically filtered

### JavaScript Error Tracking

- Honeybadger JS is loaded in production via CDN
- Captures `window.error` events
- Captures unhandled promise rejections
- Configuration is passed via meta tags in layouts

**Note on API Key Security**: Honeybadger API keys are designed to be used in frontend JavaScript code. They are write-only tokens that can only submit error reports - they cannot read data from your Honeybadger account. The keys are also rate-limited to prevent abuse. This is the recommended approach per Honeybadger's official documentation.

### Custom Error Pages

Custom error pages are served instead of static HTML files:

- **404 Not Found** - `/app/views/errors/not_found.html.erb`
- **422 Unprocessable Entity** - `/app/views/errors/unprocessable_entity.html.erb`
- **500 Internal Server Error** - `/app/views/errors/internal_server_error.html.erb`

Each error page displays a unique **Error ID** (e.g., `ERR-A1B2C3D4E5F6`) that can be:
- Shared with support for troubleshooting
- Used to search for specific errors in Honeybadger dashboard

### Error Context

The following context is automatically attached to errors:
- `user_id` - Admin user ID or "guest"
- `user_email` - Admin email or "none"
- `user_type` - "admin" or "guest"
- `error_id` - Unique error identifier (for custom error pages)

## Environments

| Environment | Reports Data | Insights |
|-------------|-------------|----------|
| Development | No | No |
| Test | No | No |
| Production | Yes | Yes |

## Ignored Errors

The following errors are ignored by default (common, non-actionable errors):
- `ActionController::RoutingError` - 404 errors
- `ActiveRecord::RecordNotFound` - Missing records
- `ActionController::InvalidAuthenticityToken` - CSRF failures

## Alert Configuration

Alert policies should be configured in the Honeybadger dashboard:
1. Log into Honeybadger at https://app.honeybadger.io
2. Navigate to Settings → Alert Channels
3. Configure notification channels (email, Slack, etc.)

### Recommended Alert Policies

1. **Critical Errors**: Immediate notification for 500 errors
2. **Error Spike**: Alert when error rate increases significantly
3. **New Errors**: Notify when a new error type is detected

## Testing Error Tracking

### Manual Test (Development)

To test that Honeybadger is configured correctly:

```ruby
# In Rails console
Honeybadger.notify("Test error from development")
```

### Verify Configuration

```bash
bundle exec honeybadger deploy -e production
```

## Debugging

### Enable Debug Mode

Set `debug: true` in `config/honeybadger.yml` to see detailed logging.

### Check Configuration

```ruby
# In Rails console
puts Honeybadger.config.to_hash
```

## Security Considerations

1. **Never commit the API key** - Always use environment variables or credentials
2. **Filtered parameters** are automatically excluded from error reports
3. **User PII** should be limited to IDs and emails

## Related Files

- `config/honeybadger.yml` - Main configuration
- `config/initializers/honeybadger.rb` - Runtime hooks
- `app/controllers/application_controller.rb` - User context
- `app/controllers/errors_controller.rb` - Custom error pages
- `app/views/errors/` - Error page templates
- `app/javascript/application.ts` - JS error tracking
- `app/views/layouts/application.html.erb` - JS config meta tags
