# GitHub Issues for Sprint 01

Use this template to create issues in your GitHub repository. Copy each issue block and create a new issue with the provided title, labels, and description.

---

## Issue 1: Fix LetterOpenerWeb Production Exposure

**Title**: [CRITICAL] Fix LetterOpenerWeb Production Exposure

**Labels**: `security`, `critical`, `bug`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 1

**Description**:
```markdown
## Problem
LetterOpenerWeb is currently mounted in production at `/letter_opener`, exposing all customer emails and order details publicly.

## Solution
Restrict LetterOpenerWeb to development environment only.

## Implementation
Update `config/routes.rb`:
```ruby
# BEFORE:
mount LetterOpenerWeb::Engine, at: '/letter_opener'

# AFTER:
if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: '/letter_opener'
end
```

## Acceptance Criteria
- [ ] Letter opener only accessible in development environment
- [ ] Production deployment verified - route returns 404
- [ ] No email data exposed via public URL
- [ ] Staging environment tested

## Testing
```bash
# In production/staging
curl https://shop.cariana.tech/letter_opener
# Should return 404
```

## Priority
CRITICAL - Must be fixed immediately
```

---

## Issue 2: Implement Rate Limiting with Rack::Attack

**Title**: [CRITICAL] Implement Rate Limiting with Rack::Attack

**Labels**: `security`, `critical`, `enhancement`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 3

**Description**:
```markdown
## Problem
Application has no rate limiting, making it vulnerable to brute force attacks, spam, and DDoS.

## Solution
Implement Rack::Attack gem with rate limiting on critical endpoints.

## Implementation

### Step 1: Add Gem
```ruby
# Gemfile
gem 'rack-attack'
```

### Step 2: Create Initializer
Create `config/initializers/rack_attack.rb` with throttles for:
- All requests by IP (300 requests/5 minutes)
- Admin login attempts (5 attempts/20 seconds)
- Checkout attempts (10 attempts/1 minute)
- Contact form submissions (5 attempts/1 minute)

### Step 3: Configure Middleware
Add to `config/application.rb`:
```ruby
config.middleware.use Rack::Attack
```

## Acceptance Criteria
- [ ] Rate limiting active on all forms
- [ ] Admin login brute force protection working (max 5 attempts/20s)
- [ ] Checkout rate limiting prevents abuse (max 10/minute)
- [ ] Contact form rate limiting active (max 5/minute)
- [ ] Throttled requests receive 429 status
- [ ] Test with automated requests to verify limits
- [ ] Monitor logs for false positives
- [ ] Documentation updated with rate limit details

## Testing
```bash
# Test admin login rate limiting
for i in {1..10}; do
  curl -X POST https://shop.cariana.tech/admin_users/sign_in \
    -d "admin_user[email]=test@test.com&admin_user[password]=wrong"
done
# Should see 429 after 5 requests
```

## Priority
CRITICAL
```

---

## Issue 3: Enable Content Security Policy

**Title**: [HIGH] Enable Content Security Policy Headers

**Labels**: `security`, `high-priority`, `enhancement`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 5

**Description**:
```markdown
## Problem
No CSP headers are configured, leaving the application vulnerable to XSS attacks.

## Solution
Configure Content Security Policy headers with report-only mode initially.

## Implementation
Update `config/initializers/content_security_policy.rb` with appropriate policies for:
- default-src
- font-src
- img-src
- script-src (Google Analytics)
- style-src (Tailwind)
- connect-src

Start in report-only mode, monitor violations, then switch to enforcement.

## Acceptance Criteria
- [ ] CSP headers active in production
- [ ] No console errors on any page (home, products, admin, checkout)
- [ ] Google Analytics still functioning
- [ ] All images loading correctly
- [ ] Font Awesome icons displaying
- [ ] Tailwind styles working
- [ ] Report violations logged to Rails logger
- [ ] After testing period, switch to enforcement mode

## Testing Checklist
- [ ] Home page loads without CSP violations
- [ ] Product pages display correctly
- [ ] Admin dashboard renders properly
- [ ] Cart functionality works
- [ ] Checkout flow completes
- [ ] Contact form submits
- [ ] Quantity calculators function

## Priority
HIGH

## Risk
High risk of breaking functionality. Use report-only mode first.
```

---

## Issue 4: Implement Functional Contact Form

**Title**: [HIGH] Implement Functional Contact Form with Email Delivery

**Labels**: `feature`, `high-priority`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 5

**Description**:
```markdown
## Problem
Contact form currently shows success message but doesn't send any email or store data.

## Solution
Implement ContactMailer with full validation and email delivery.

## Implementation

### Step 1: Create ContactMailer
- Create `app/mailers/contact_mailer.rb`
- Create email template at `app/views/contact_mailer/contact_email.html.erb`

### Step 2: Update Controller
Update `app/controllers/contact_controller.rb` with:
- Strong parameters
- Validation logic (all fields required + email format)
- Email delivery via `deliver_later`
- Proper error handling

### Step 3: Configure Environment Variable
Add `ADMIN_EMAIL` to environment configuration.

## Acceptance Criteria
- [ ] Email sent to admin on valid form submission
- [ ] Validation prevents empty first name
- [ ] Validation prevents empty last name
- [ ] Validation prevents empty email
- [ ] Validation prevents empty message
- [ ] Email format validated (must be valid email)
- [ ] Test email received in development (letter_opener)
- [ ] Production email confirmed working (MailerSend)
- [ ] Email includes all form fields
- [ ] Reply-to header set to customer email
- [ ] Error messages displayed for invalid submissions

## Environment Configuration
```bash
ADMIN_EMAIL=admin@cariana.tech
```

## Priority
HIGH
```

---

## Issue 5: Add Contact Form Tests

**Title**: [HIGH] Add Contact Form Tests

**Labels**: `testing`, `high-priority`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 2

**Description**:
```markdown
## Problem
Contact controller has no tests. Need comprehensive test coverage.

## Solution
Create comprehensive tests for ContactController and ContactMailer.

## Implementation
Create test files:
- `test/controllers/contact_controller_test.rb`
- `test/mailers/contact_mailer_test.rb`

## Test Coverage Required
### Controller Tests
- [ ] GET index returns success
- [ ] Valid submission sends email
- [ ] Valid submission redirects with success message
- [ ] Missing first name rejected
- [ ] Missing last name rejected
- [ ] Missing email rejected
- [ ] Invalid email format rejected
- [ ] Missing message rejected

### Mailer Tests
- [ ] Email has correct recipient
- [ ] Email has correct subject
- [ ] Email has reply-to header
- [ ] Email contains message content

## Acceptance Criteria
- [ ] All contact controller tests passing
- [ ] All contact mailer tests passing
- [ ] Tests verify email delivery
- [ ] Tests verify validation logic
- [ ] Tests verify error messages
- [ ] Code coverage >90% for contact controller

## Priority
HIGH

## Dependencies
Must be completed after Issue #4 (Implement Functional Contact Form)
```

---

## Issue 6: Add Comprehensive Webhook Tests

**Title**: [HIGH] Add Comprehensive Webhook Controller Tests

**Labels**: `testing`, `high-priority`, `critical-path`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 8

**Description**:
```markdown
## Problem
WebhooksController has zero tests despite being the most critical code path (order creation, stock updates, email sending).

## Solution
Create comprehensive test suite for webhook handling with Stripe test fixtures.

## Implementation

### Step 1: Create Test Fixtures
Create `test/fixtures/files/stripe/checkout_completed.json` with mock Stripe webhook data.

### Step 2: Create Test Helper
Create `test/support/stripe_test_helpers.rb` with:
- `load_stripe_fixture(name)`
- `generate_stripe_signature(payload)`
- `post_stripe_webhook(event_type, data)`

### Step 3: Create Webhook Tests
Create `test/controllers/webhooks_controller_test.rb` with comprehensive test cases.

## Test Coverage Required
- [ ] Valid webhook creates order
- [ ] Order has correct customer details
- [ ] Order products created with correct data
- [ ] Stock levels decremented correctly
- [ ] Confirmation email queued
- [ ] Invalid signature rejected (400)
- [ ] Missing signature rejected (400)
- [ ] Unhandled event types logged gracefully

## Acceptance Criteria
- [ ] All 8+ webhook tests passing
- [ ] Code coverage >80% for webhooks controller
- [ ] Test fixtures created
- [ ] Test helpers documented
- [ ] Edge cases covered (missing data, invalid data)

## Priority
HIGH - Critical payment flow must be tested

## Estimated Effort
8 story points - This is complex due to Stripe signature generation and mocking
```

---

## Issue 7: Add Webhook Integration Test Helper

**Title**: [MEDIUM] Create Reusable Stripe Webhook Test Helper

**Labels**: `testing`, `medium-priority`, `developer-experience`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 2

**Description**:
```markdown
## Problem
Stripe webhook testing requires complex signature generation. Need reusable helper for future tests.

## Solution
Create StripeTestHelpers module with reusable methods.

## Implementation
Create `test/support/stripe_test_helpers.rb` and include in test_helper.rb.

## Helper Methods
- `load_stripe_fixture(name)` - Load JSON fixtures
- `generate_stripe_signature(payload)` - Generate valid Stripe signature
- `post_stripe_webhook(event_type, data)` - Simplified webhook posting

## Acceptance Criteria
- [ ] Helper methods available in all integration tests
- [ ] Signature generation reusable
- [ ] Fixture loading simplified
- [ ] Documentation added for usage
- [ ] Can be used in future webhook tests

## Priority
MEDIUM

## Dependencies
Should be completed as part of Issue #6 (Webhook Tests)
```

---

## Issue 8: Extract Webhook Logic to OrderProcessor Service

**Title**: [HIGH] Refactor: Extract Webhook Logic to OrderProcessor Service

**Labels**: `refactoring`, `high-priority`, `code-quality`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 8

**Description**:
```markdown
## Problem
WebhooksController#stripe is 90+ lines of complex logic, violating Single Responsibility Principle.

## Solution
Extract business logic to OrderProcessor service object.

## Implementation

### Step 1: Create Service Object
Create `app/services/order_processor.rb` with methods:
- `initialize(stripe_session)`
- `process` - Main processing method
- Private methods for each step (create_order, create_order_products, etc.)

### Step 2: Refactor Controller
Update `app/controllers/webhooks_controller.rb` to use service:
```ruby
processor = OrderProcessor.new(session)
if processor.process
  render json: { message: 'success' }
else
  # Handle errors
end
```

### Step 3: Add Service Tests
Create `test/services/order_processor_test.rb` with comprehensive coverage.

## Acceptance Criteria
- [ ] Webhook controller under 50 lines
- [ ] All business logic in OrderProcessor
- [ ] Service object fully tested
- [ ] Controller tests updated and passing
- [ ] Error handling improved with logging
- [ ] Honeybadger notifications include context
- [ ] Transaction rollback on any failure
- [ ] All existing webhook tests still passing
- [ ] Code more maintainable and readable

## Benefits
- ✅ Single Responsibility: Controller handles HTTP, Service handles business logic
- ✅ Testability: Service can be tested independently
- ✅ Reusability: Service can be called from console, rake tasks, etc.
- ✅ Error Handling: Centralized error handling and logging
- ✅ Maintainability: Easier to understand and modify

## Priority
HIGH - Critical for long-term maintainability

## Risk
Medium - Must not break order processing. Requires extensive testing.

## Dependencies
Should be completed after Issue #6 (Webhook Tests)
```

---

## Issue 9: Implement Model Scopes

**Title**: [MEDIUM] Add Model Scopes for Cleaner Queries

**Labels**: `refactoring`, `medium-priority`, `code-quality`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 3

**Description**:
```markdown
## Problem
No scopes defined in models. Business logic repeated across controllers.

## Solution
Add scopes to Order, Product, Category, and Stock models.

## Implementation

### Order Scopes
- `unfulfilled`, `fulfilled`
- `for_month(date)`, `for_date_range(start, end)`
- `recent(limit)`, `with_email(email)`

### Product Scopes
- `active`, `inactive`
- `in_price_range(min, max)`
- `with_stock`, `out_of_stock`, `low_stock(threshold)`
- `by_category(id)`, `search_by_name(query)`

### Category Scopes
- `with_active_products`
- `with_products_in_stock`

### Stock Scopes
- `in_stock`, `out_of_stock`, `low_stock(threshold)`
- `for_size(size)`

## Acceptance Criteria
- [ ] Scopes defined on all models
- [ ] Scopes tested in model tests
- [ ] Scopes chainable (e.g., `Product.active.with_stock`)
- [ ] No breaking changes to existing queries
- [ ] Documentation added to models

## Priority
MEDIUM
```

---

## Issue 10: Refactor Controllers to Use Scopes

**Title**: [MEDIUM] Refactor Controllers to Use Model Scopes

**Labels**: `refactoring`, `medium-priority`, `code-quality`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 2

**Description**:
```markdown
## Problem
Controllers use inline where clauses instead of readable scopes.

## Solution
Update all controllers to use newly defined model scopes.

## Implementation
Update these controllers:
- `AdminController` - Use `Order.unfulfilled.recent(5)` and `Order.for_month`
- `Admin::OrdersController` - Use `Order.unfulfilled`
- `CategoriesController` - Use `Product.active.in_price_range(min, max)`

## Acceptance Criteria
- [ ] All controllers refactored
- [ ] No SQL changes (same queries, cleaner code)
- [ ] All tests still passing
- [ ] Code more readable and maintainable
- [ ] Performance unchanged

## Priority
MEDIUM

## Dependencies
Must be completed after Issue #9 (Implement Model Scopes)
```

---

## Issue 11: Implement Comprehensive Error Logging

**Title**: [MEDIUM] Implement Comprehensive Error Logging & Monitoring

**Labels**: `monitoring`, `medium-priority`, `developer-experience`, `sprint-01`

**Milestone**: Sprint 01

**Story Points**: 5

**Description**:
```markdown
## Problem
Only 1 `Rails.logger` call exists. No structured logging. Difficult to debug production issues.

## Solution
Implement structured logging throughout the application with Honeybadger integration.

## Implementation

### Step 1: Update ApplicationController
Add global error handlers:
- `rescue_from ActiveRecord::RecordNotFound`
- `rescue_from ActiveRecord::RecordInvalid`
- `rescue_from StandardError`
- Add `before_action :log_request_info`

### Step 2: Add Structured Logging
Log with context:
- Request ID
- IP address
- User agent
- Filtered parameters
- Error backtraces

### Step 3: Update CheckoutsController
Add Stripe-specific error logging.

### Step 4: Create Custom Error Pages
Update `public/404.html` and `public/500.html` with user-friendly messages.

## Acceptance Criteria
- [ ] Structured logging implemented
- [ ] All errors logged with context (request ID, params, etc.)
- [ ] Request ID tracked throughout request lifecycle
- [ ] Honeybadger receives full error context
- [ ] Custom error pages for 404/500
- [ ] Logs are JSON-formatted for easy parsing
- [ ] Sensitive data filtered from logs (passwords, tokens)

## Priority
MEDIUM

## Benefits
- Easier debugging of production issues
- Better visibility into application health
- Faster incident response
```

---

## Summary

**Total Issues**: 11
**Total Story Points**: 44

### By Priority
- **CRITICAL**: 2 issues (4 points)
- **HIGH**: 5 issues (25 points)
- **MEDIUM**: 4 issues (15 points)

### By Category
- **Security**: 3 issues (9 points)
- **Features**: 1 issue (5 points)
- **Testing**: 3 issues (12 points)
- **Refactoring**: 3 issues (13 points)
- **Monitoring**: 1 issue (5 points)

### Dependencies
```
Issue 1 (LetterOpener) → No dependencies
Issue 2 (Rate Limiting) → No dependencies
Issue 3 (CSP) → No dependencies
Issue 4 (Contact Form) → No dependencies
Issue 5 (Contact Tests) → Depends on #4
Issue 6 (Webhook Tests) → No dependencies
Issue 7 (Test Helper) → Part of #6
Issue 8 (OrderProcessor) → Depends on #6
Issue 9 (Model Scopes) → No dependencies
Issue 10 (Controller Refactor) → Depends on #9
Issue 11 (Error Logging) → No dependencies
```

### Suggested Sprint Schedule
**Week 1 (Days 1-5)**:
- Days 1-2: Issues #1, #2, #3 (Security fixes)
- Days 3-4: Issues #4, #5 (Contact form)
- Day 5: Issues #6, #7 (Webhook tests)

**Week 2 (Days 6-10)**:
- Days 6-7: Issue #8 (OrderProcessor refactoring)
- Days 8-9: Issues #9, #10 (Model scopes)
- Day 10: Issue #11 (Error logging)

---

## How to Create Issues

1. Go to your GitHub repository
2. Click "Issues" → "New Issue"
3. Copy the title from each issue above
4. Copy the description markdown
5. Add the labels listed
6. Set the milestone to "Sprint 01"
7. Optionally add story points using GitHub Projects or ZenHub

## Tracking Progress

Use GitHub Projects to:
- Create a Sprint 01 board
- Move issues through columns: To Do → In Progress → Review → Done
- Track story points completed
- Monitor sprint burndown
