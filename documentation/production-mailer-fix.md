# Production Mailer Configuration Fix

## Issue
**HoneyBadger Error**: `ArgumentError: Missing host to link to!`  
**Location**: `Users::RegistrationsController#create` (line 7)  
**Impact**: Users unable to register in production environment

## Root Cause

When a user registers in the application:

1. Devise creates a new user record with `confirmed_at: nil`
2. Devise triggers the `:confirmable` module to send a confirmation email
3. The confirmation email contains URLs linking to the confirmation page
4. Rails Action Mailer needs `default_url_options[:host]` to generate these URLs
5. **In production**, this configuration was missing, causing the error

## The Fix

### Configuration Change
Added to `config/environments/production.rb`:

```ruby
# Configure default URL options for Action Mailer (required for Devise emails with links)
config.action_mailer.default_url_options = { host: 'shop.cariana.tech', protocol: 'https' }
```

### Why This Specific Configuration?

1. **Host**: `shop.cariana.tech` matches the configured `config.hosts` in production
2. **Protocol**: `https` ensures all links in emails use secure HTTPS protocol
3. **Placement**: Added near other mailer configuration for maintainability

## Testing

### Controller Test
Added test in `test/controllers/users/registrations_controller_test.rb`:

```ruby
test 'registration sends confirmation email' do
  assert_difference 'ActionMailer::Base.deliveries.size', 1 do
    post user_registration_path, params: @user_params
  end

  email = ActionMailer::Base.deliveries.last
  assert_equal [@user_params[:user][:email]], email.to
  assert_match(/confirm/i, email.subject)
  # Verify email contains a confirmation URL
  assert_match %r{http://localhost:3000/users/confirmation}, email.body.encoded
end
```

### Environment Configuration Test
Created `test/config/environments_test.rb` to ensure:

1. Production has `default_url_options` with correct host and protocol
2. Development has `default_url_options` configured
3. Test environment has `default_url_options` configured

This prevents regression if the configuration is accidentally removed.

## Verification Steps

### In Production
1. User submits registration form
2. User record created with `confirmed_at: nil`
3. Confirmation email sent successfully (no error)
4. Email contains link: `https://shop.cariana.tech/users/confirmation?confirmation_token=...`
5. User clicks link and confirms their account

### In Development/Test
Same flow works with `http://localhost:3000` as the host.

## Related Configuration

### Development (`config/environments/development.rb`)
```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

### Test (`config/environments/test.rb`)
```ruby
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

## Other Devise Features Requiring URL Generation

The same `default_url_options` configuration is required for:

- **Password Reset**: `reset_password_instructions` email
- **Unlock Account**: `unlock_instructions` email (if `:lockable` is enabled)
- **Email Change Confirmation**: `reconfirmation_instructions` email

## Best Practices

1. **Always set `default_url_options`** in all environments when using Devise
2. **Match the protocol** to your environment (https in production, http in development)
3. **Match the host** to your `config.hosts` configuration
4. **Test email generation** in a production-like environment before deploying

## Additional Notes

### Why Not Use Environment Variables?

While you could use:
```ruby
config.action_mailer.default_url_options = { host: ENV['APP_HOST'], protocol: 'https' }
```

We use the hardcoded value because:
- It's already defined in `config.hosts`
- Reduces environment variable complexity
- Makes the configuration self-documenting
- Easier to validate in tests

### Impact on Other Features

This fix also benefits:
- Any Action Mailer emails that include URLs (e.g., password reset)
- Background jobs that send emails
- Any `*_url` helper used in email templates

## References

- [Devise Configuration](https://github.com/heartcombo/devise#configuring-models)
- [Rails Action Mailer Configuration](https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration)
- [HoneyBadger Error Report](https://app.honeybadger.io/projects/135923/faults/125700625)

## Timeline

- **Issue Reported**: Production deployment
- **Issue Identified**: Missing `default_url_options` in production.rb
- **Fix Applied**: Added configuration to production.rb
- **Tests Added**: Controller test + Environment configuration tests
- **Status**: ✅ Resolved
