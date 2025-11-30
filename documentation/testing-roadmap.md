# Testing Roadmap for Critical Paths

**Last Updated**: November 30, 2025
**Current Coverage**: 86.22% (648 runs, 1,447 assertions, 0 failures)

---

## Executive Summary

This document outlines the testing strategy and roadmap for the e-commerce Rails 7 application. While the overall test coverage is strong at 86.22%, there are critical gaps in system-level integration tests, particularly for the payment flow (WebhooksController has **zero** tests). This roadmap prioritizes closing these gaps to ensure production reliability.

---

## Current Test Coverage Analysis

### Overall Metrics (November 30, 2025)

| Metric | Value | Status |
|--------|-------|--------|
| **Total Test Runs** | 648 | ✅ Good |
| **Total Assertions** | 1,447 | ✅ Good |
| **Test Failures** | 0 | ✅ Excellent |
| **Overall Coverage** | 86.22% | ✅ Good |
| **Unit Coverage** | 83.6% | ✅ Good |
| **System Coverage** | 47.84% | ⚠️ Needs Improvement |
| **Test Execution Time** | ~50 seconds | ✅ Good (CI/CD ready) |

### Coverage by Layer

```
┌─────────────────────────────────────────────┐
│ Unit Tests (Models, Helpers, Mailers)      │
│ ████████████████████████████████████ 83.6% │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ System Tests (Controllers, Integration)     │
│ ████████████████████             47.84%     │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Overall Coverage                             │
│ █████████████████████████████████ 86.22%    │
└─────────────────────────────────────────────┘
```

---

## ✅ Well-Tested Critical Paths (>80% coverage)

### 1. Product Management (Unit: 83.6%)

**Test File**: `test/models/product_test.rb` (72 test methods)

**Coverage Highlights**:
- ✅ **Validations**: name, price, stock_level, shipping dimensions (weight, length, width, height)
- ✅ **Scopes**: active, in_price_range, fiberglass_reinforcement, in_weight_range, sorted_by
- ✅ **Full-text search**: pg_search scope (search_by_text)
  - Searches product name, description, category name
  - Case-insensitive, prefix matching
  - Chainable with other scopes
- ✅ **Active Storage**: Image attachments with variants (thumb, medium, webp)
- ✅ **Admin CRUD**: Admin::ProductsController operations
- ✅ **PaperTrail**: Audit tracking for create, update, destroy

**Example Test**:
```ruby
test 'search_by_text scope searches by product name' do
  results = Product.search_by_text('Chopped')
  assert results.any?, 'Should find products by name'
end

test 'sorted_by price_asc sorts products by price ascending' do
  products = Product.sorted_by('price_asc')
  prices = products.pluck(:price)
  assert_equal prices.sort, prices
end
```

**Risk Level**: ✅ Low (comprehensive coverage)

---

### 2. Category Management

**Test File**: `test/models/category_test.rb`

**Coverage Highlights**:
- ✅ **Validations**: name (presence, uniqueness case-insensitive)
- ✅ **Cascade delete**: Products deleted when category deleted
- ✅ **Admin CRUD**: Admin::CategoriesController operations
- ✅ **PaperTrail**: Audit tracking
- ✅ **Active Storage**: Single image attachment with variants

**Risk Level**: ✅ Low

---

### 3. Stock Management

**Test File**: `test/models/stock_test.rb`

**Coverage Highlights**:
- ✅ **Validations**: size, price, stock_level, shipping dimensions
- ✅ **Nested routes**: `/admin/products/:product_id/stocks`
- ✅ **Size variant pricing**: Different prices for Small, Medium, Large, etc.
- ✅ **PaperTrail**: Audit tracking

**Risk Level**: ✅ Low

---

### 4. Order Processing

**Test File**: `test/models/order_test.rb`

**Coverage Highlights**:
- ✅ **Validations**: customer_email (format), total, address, name
- ✅ **Scopes**: unfulfilled, fulfilled, recent(limit), for_month(date)
- ✅ **PaperTrail**: Audit tracking
- ✅ **Admin fulfillment**: Workflow for marking orders fulfilled

**Risk Level**: ✅ Low

---

### 5. Material Quantity Calculators

**Test File**: `test/services/quantity_calculator_service_test.rb`

**Coverage Highlights**:
- ✅ **Service methods**: calculate_area, calculate_dimensions, calculate_mould_rectangle
- ✅ **Constants**: MATERIAL_WIDTH (0.95m), RESIN_TO_GLASS_RATIO (1.6:1), WASTAGE_FACTOR (1.15)
- ✅ **Material types**: 14 types (Chop Strand 300g/450g/600g, Plain Weave 285g/400g, etc.)
- ✅ **Formulas**: Mat, resin, catalyst calculations
- ✅ **Controllers**: Quantities::AreaController, DimensionsController, MouldRectangleController

**Risk Level**: ✅ Low

---

### 6. Cart System (Hybrid Client+Server)

**Test Files**: `test/models/cart_test.rb`, `test/models/cart_item_test.rb`

**Coverage Highlights**:
- ✅ **Cart model**: session_token (unique), 30-day expiry, merge_items!
- ✅ **CartItem model**: Validations, refresh_price!, stock_available?
- ✅ **Cart API**: POST/GET/PATCH/DELETE `/api/carts`
- ✅ **LocalStorage integration**: Client-side + server persistence

**Risk Level**: ✅ Low

---

### 7. Admin Authentication & 2FA

**Test Files**: `test/models/admin_user_test.rb`, `test/controllers/admin_users/two_factor_controller_test.rb`

**Coverage Highlights**:
- ✅ **Devise authentication**: AdminUser model
- ✅ **Two-Factor Authentication**: Setup flow with QR code
- ✅ **TOTP verification**: devise-two-factor gem
- ✅ **Backup codes**: 10 codes generated, validated, consumed
- ✅ **2FA management UI**: Enable/disable, regenerate codes

**Risk Level**: ✅ Low

---

### 8. Audit Logging (PaperTrail)

**Test File**: `test/models/paper_trail_audit_test.rb`

**Coverage Highlights**:
- ✅ **4 audited models**: Product, Category, Stock, Order
- ✅ **Version tracking**: create, update, destroy events
- ✅ **Changeset parsing**: YAML before/after values
- ✅ **Whodunnit**: User tracking via `user_for_paper_trail`
- ✅ **Admin UI**: `/admin/audit_logs` with filters, CSV export
- ✅ **Retention policy**: 90-day cleanup task

**Audited Models**:
1. **Product** - `has_paper_trail` ✅
2. **Category** - `has_paper_trail` ✅
3. **Stock** - `has_paper_trail` ✅
4. **Order** - `has_paper_trail` ✅

**Not Audited**: Cart, CartItem, OrderProduct, AdminUser

**Risk Level**: ✅ Low

---

## ⚠️ Critical Paths Needing Additional Tests (<60% coverage)

### 1. Stripe Payment Flow (CRITICAL PRIORITY) 🔴

**Affected Files**:
- `app/controllers/webhooks_controller.rb` - **NO TESTS** (0% coverage)
- `app/controllers/checkouts_controller.rb` - Partial coverage (~50%)

**Risk Level**: 🔴 **CRITICAL** - Payment processing must be bulletproof

#### WebhooksController - Missing Tests

**Current State**: Zero tests for the most critical controller in the application.

**Required Tests** (Priority: CRITICAL):

1. **✅ Successful `checkout.session.completed` webhook**
   ```ruby
   test "successful checkout webhook creates order and decrements stock" do
     # Simulate Stripe webhook with valid signature
     # Assert order created, stock decremented, email sent
   end
   ```

2. **✅ Order creation from Stripe session metadata**
   ```ruby
   test "webhook parses Stripe metadata correctly" do
     # Verify product_id, size, product_stock_id, product_price extracted
   end
   ```

3. **✅ Stock decrement logic (product vs variant pricing)**
   ```ruby
   test "webhook decrements product stock_level when no stock_id" do
     # Product has direct stock_level field
   end

   test "webhook decrements Stock model when stock_id present" do
     # Variant pricing via Stock model
   end
   ```

4. **✅ Email sending**
   ```ruby
   test "webhook sends order confirmation email" do
     assert_difference 'ActionMailer::Base.deliveries.size', 1 do
       # Process webhook
     end
   end
   ```

5. **❌ Invalid signature rejection**
   ```ruby
   test "webhook rejects invalid Stripe signature" do
     # Simulate webhook with bad signature
     # Assert 400 response, no order created
   end
   ```

6. **❌ Idempotency (duplicate webhook handling)**
   ```ruby
   test "duplicate webhook does not create duplicate orders" do
     # Process same webhook twice
     # Assert only one order created
   end
   ```

7. **❌ Error handling**
   ```ruby
   test "webhook handles stock decrement failure gracefully" do
     # Product out of stock, cannot decrement
     # Assert error logged, order still created (business decision)
   end

   test "webhook handles email failure gracefully" do
     # SMTP error during email send
     # Assert order still created, error logged
   end
   ```

**Implementation Plan** (Sprint 1 - Week 1):
```bash
# Day 1-2: Setup Stripe test mode webhook simulation
# Day 3-4: Write 7 webhook tests (success, order, stock, email, signature, idempotency, errors)
# Day 5: Add integration test with real Stripe test mode webhook
```

**Success Criteria**:
- WebhooksController coverage: 0% → 80%+
- All edge cases covered (invalid signature, duplicate webhooks, errors)
- Integration test with Stripe test mode

---

#### CheckoutsController - Edge Case Coverage

**Current State**: ~50% coverage (basic happy path tested)

**Required Tests** (Priority: HIGH):

1. **❌ Empty cart handling**
   ```ruby
   test "checkout fails with empty cart" do
     # Simulate checkout with empty localStorage cart
     # Assert 400 response, helpful error message
   end
   ```

2. **❌ Invalid product ID handling**
   ```ruby
   test "checkout fails with non-existent product" do
     # Cart contains deleted/invalid product ID
     # Assert 400 response, error message
   end
   ```

3. **❌ Out-of-stock product handling**
   ```ruby
   test "checkout fails when product out of stock" do
     # Product.stock_level = 0 or Stock.stock_level = 0
     # Assert 400 response, stock error message
   end
   ```

4. **❌ Stripe API error handling**
   ```ruby
   test "checkout handles Stripe API error gracefully" do
     # Mock Stripe::InvalidRequestError
     # Assert 500 response, error logged to Honeybadger
   end
   ```

5. **❌ Concurrent checkout race condition**
   ```ruby
   test "concurrent checkouts for last item in stock" do
     # Two users checkout simultaneously for product with stock_level=1
     # Assert one succeeds, one fails with stock error
   end
   ```

**Implementation Plan** (Sprint 2 - Week 1):
```bash
# Day 1-2: Write 4 edge case tests (empty cart, invalid product, out-of-stock, API error)
# Day 3-4: Write concurrency test with threads
# Day 5: Add stress test (100 concurrent checkouts)
```

**Success Criteria**:
- CheckoutsController coverage: 50% → 75%+
- Race condition tests passing
- Graceful error handling verified

---

### 2. Admin Dashboard Aggregations (MEDIUM PRIORITY) 🟡

**Affected Files**:
- `app/controllers/admin_controller.rb` - Partial coverage
- `app/controllers/admin/reports_controller.rb` - Partial coverage

**Risk Level**: 🟡 **MEDIUM** - Business metrics must be accurate

**Required Tests** (Priority: MEDIUM):

1. **✅ Monthly stats calculation**
   ```ruby
   test "monthly_stats calculates correctly" do
     # Verify sales, items, revenue, avg_sale, shipping calculations
   end
   ```

2. **✅ Daily revenue breakdown**
   ```ruby
   test "revenue_by_month fills missing days with zero" do
     # Month has gaps (e.g., no orders on weekends)
     # Assert all days 1-31 present, zeros for missing days
   end
   ```

3. **❌ No orders in month edge case**
   ```ruby
   test "monthly_stats handles month with zero orders" do
     # Current month has no orders
     # Assert all stats are 0, no division by zero errors
   end
   ```

4. **❌ Month boundary calculations**
   ```ruby
   test "monthly_stats handles cross-month orders correctly" do
     # Order created on last day of month vs first day of next month
     # Assert correct month attribution
   end
   ```

5. **❌ Performance with large datasets**
   ```ruby
   test "monthly_stats performs well with 10k+ orders" do
     # Seed 10,000 orders
     # Assert query time < 500ms
   end
   ```

**Implementation Plan** (Sprint 3 - Week 1):
```bash
# Day 1-2: Write 3 edge case tests (no orders, month boundaries, large datasets)
# Day 3-4: Add performance benchmark (target: <500ms for 10k orders)
# Day 5: Optimize queries if needed (eager loading, database indexes)
```

**Success Criteria**:
- Admin dashboard coverage: 60% → 80%+
- All edge cases handled gracefully
- Performance benchmark: <500ms for 10k orders

---

### 3. Email Delivery (LOW PRIORITY) 🟢

**Affected Files**:
- `app/mailers/order_mailer.rb` - Partial coverage
- SMTP integration - No integration tests

**Risk Level**: 🟢 **LOW** - Emails work in production, but edge cases not tested

**Required Tests** (Priority: LOW):

1. **✅ OrderMailer.new_order_email format**
   ```ruby
   test "new_order_email includes all required fields" do
     # Assert email contains: customer name, order total, VAT breakdown, product list
   end
   ```

2. **❌ Email delivery success**
   ```ruby
   test "email delivers successfully in development" do
     # Verify letter_opener_web captures email
   end
   ```

3. **❌ SMTP failure handling**
   ```ruby
   test "SMTP error is logged and does not crash webhook" do
     # Mock Net::SMTPFatalError
     # Assert error logged to Honeybadger, webhook continues
   end
   ```

4. **❌ Template rendering with images**
   ```ruby
   test "email template renders product images correctly" do
     # Product has multiple images
     # Assert email includes image URLs
   end
   ```

**Implementation Plan** (Sprint 4 - Week 1):
```bash
# Day 1-2: Write 3 email delivery tests
# Day 3: Test SMTP failure simulation
# Day 4-5: Test template rendering edge cases
```

---

### 4. Image Upload & Processing (LOW PRIORITY) 🟢

**Affected Files**:
- `app/controllers/admin/products_controller.rb` - Custom duplicate filename logic (lines 47-59)
- Active Storage integration - Edge cases not tested

**Risk Level**: 🟢 **LOW** - Custom logic exists, but low risk

**Required Tests** (Priority: LOW):

1. **✅ Duplicate filename prevention**
   ```ruby
   test "update prevents duplicate filenames" do
     # Upload image "product.jpg", then upload new "product.jpg"
     # Assert old image purged, new image attached
   end
   ```

2. **❌ VIPS processing errors**
   ```ruby
   test "image variant generation handles VIPS errors" do
     # Upload corrupted image file
     # Assert error handled gracefully
   end
   ```

3. **❌ Large file uploads**
   ```ruby
   test "image upload handles files >10MB" do
     # Upload 15MB image
     # Assert error or successful processing
   end
   ```

4. **❌ Invalid file type handling**
   ```ruby
   test "image upload rejects non-image files" do
     # Upload .exe or .txt file
     # Assert validation error
   end
   ```

**Implementation Plan** (Sprint 4 - Week 2):
```bash
# Day 1: Write 3 image processing error tests
# Day 2: Test large file uploads
# Day 3: Test file type validation
```

---

## 🎯 Sprint Testing Priorities (Q1 2026)

### Sprint 1: WebhooksController Tests (Priority: CRITICAL)

**Duration**: 2 weeks
**Goal**: Achieve 80%+ coverage for payment flow

**Week 1 - Setup & Core Tests**:
- Day 1-2: Setup Stripe test mode webhook simulation (use `stripe-ruby-mock` gem or VCR)
- Day 3: Write success webhook test (order creation)
- Day 4: Write stock decrement tests (product vs variant)
- Day 5: Write email sending test

**Week 2 - Edge Cases & Integration**:
- Day 1: Write invalid signature test
- Day 2: Write idempotency test (duplicate webhooks)
- Day 3: Write error handling tests (stock failure, email failure)
- Day 4-5: Add real Stripe test mode integration test

**Success Metrics**:
- WebhooksController coverage: 0% → 80%+
- 7 unit tests passing
- 1 integration test passing
- All edge cases covered

---

### Sprint 2: CheckoutsController Edge Cases (Priority: HIGH)

**Duration**: 2 weeks
**Goal**: Harden checkout against race conditions and errors

**Week 1 - Edge Case Tests**:
- Day 1: Write empty cart test
- Day 2: Write invalid product ID test
- Day 3: Write out-of-stock test
- Day 4: Write Stripe API error test
- Day 5: Review and refactor

**Week 2 - Concurrency & Stress Tests**:
- Day 1-2: Write concurrent checkout test (thread-based)
- Day 3-4: Write stress test (100 concurrent checkouts)
- Day 5: Performance tuning if needed

**Success Metrics**:
- CheckoutsController coverage: 50% → 75%+
- 5 edge case tests passing
- 2 concurrency tests passing
- No race conditions detected

---

### Sprint 3: Admin Dashboard Accuracy (Priority: MEDIUM)

**Duration**: 2 weeks
**Goal**: Ensure business metrics are always accurate

**Week 1 - Edge Case Tests**:
- Day 1: Write "no orders in month" test
- Day 2: Write "month boundary" test
- Day 3: Write "large dataset" test (10k orders)
- Day 4-5: Optimize queries if performance test fails

**Week 2 - Performance Benchmarking**:
- Day 1-2: Add detailed performance benchmark (measure query time)
- Day 3: Add database indexes if needed
- Day 4: Add eager loading (`.includes`) if N+1 queries found
- Day 5: Verify < 500ms target achieved

**Success Metrics**:
- Admin dashboard coverage: 60% → 80%+
- All edge cases handled gracefully
- Performance benchmark: <500ms for 10k orders
- No N+1 queries in dashboard

---

### Sprint 4: Email & Image Processing (Priority: LOW)

**Duration**: 2 weeks
**Goal**: Reduce customer support tickets for emails and images

**Week 1 - Email Delivery Tests**:
- Day 1: Write email delivery success test
- Day 2: Write SMTP failure test
- Day 3: Write template rendering test
- Day 4-5: Test HTML vs plain text email formats

**Week 2 - Image Processing Tests**:
- Day 1: Write VIPS error test
- Day 2: Write large file upload test (>10MB)
- Day 3: Write invalid file type test
- Day 4-5: Add file size/type validation to Product model

**Success Metrics**:
- Email coverage: 50% → 70%+
- Image processing coverage: 40% → 65%+
- All error scenarios tested

---

## 📊 Test Metrics & Goals

### Current State (November 30, 2025)

| Metric | Current Value |
|--------|--------------|
| Total Test Runs | 648 |
| Total Assertions | 1,447 |
| Test Failures | 0 |
| Unit Coverage | 83.6% |
| System Coverage | 47.84% |
| Overall Coverage | 86.22% |
| Test Execution Time | ~50 seconds |

### Q1 2026 Goals

| Metric | Current | Q1 2026 Goal | Change |
|--------|---------|--------------|--------|
| Total Test Runs | 648 | 750+ | +102 (+15.7%) |
| Total Assertions | 1,447 | 1,800+ | +353 (+24.4%) |
| Unit Coverage | 83.6% | 85%+ | +1.4% |
| System Coverage | 47.84% | 70%+ | +22.16% |
| Overall Coverage | 86.22% | 88%+ | +1.78% |
| WebhooksController | 0% | 80%+ | +80% |
| CheckoutsController | ~50% | 75%+ | +25% |

---

## 🔧 Testing Tools & Best Practices

### Frameworks

- **Minitest**: Rails default (not RSpec)
- **Capybara + Selenium**: System tests with 1400x1400 screen size
- **Parallel Execution**: `workers: :number_of_processors`

### Test Commands

```bash
# Unit + integration tests (648 runs)
bin/rails test

# System tests (16 runs, browser-based)
bin/rails test:system

# All tests (664 total)
bin/rails test:all

# Coverage report (SimpleCov)
COVERAGE=true bin/rails test:all
open coverage/index.html
```

### Test Data (Fixtures)

All fixtures loaded automatically via `fixtures :all`:

```ruby
# test/fixtures/products.yml
product_one:
  name: Chopped Strand Mat 300g
  price: 1500
  stock_level: 100
  category: category_one

# test/fixtures/admin_users.yml
admin_user_one:
  email: admin@example.com
  encrypted_password: <%= Devise::Encryptor.digest(AdminUser, 'password123') %>
```

### Authentication in Tests

```ruby
# Admin controller tests
class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in admin_users(:admin_user_one)
  end

  test "index renders successfully" do
    get admin_products_url
    assert_response :success
  end
end
```

### Best Practices

1. **Arrange-Act-Assert Pattern**:
   ```ruby
   test "product price must be non-negative" do
     # Arrange
     product = products(:product_one)

     # Act
     product.price = -100

     # Assert
     assert_not product.valid?
     assert_includes product.errors[:price], "must be greater than or equal to 0"
   end
   ```

2. **Use `assert_difference` for counting**:
   ```ruby
   test "creating product increments count" do
     assert_difference 'Product.count', 1 do
       Product.create!(name: 'New Product', price: 1000, category: categories(:category_one))
     end
   end
   ```

3. **Mock external APIs**:
   ```ruby
   test "checkout creates Stripe session" do
     # Use stripe-ruby-mock or VCR to mock Stripe API
     VCR.use_cassette('stripe_session_create') do
       post checkout_url
       assert_response :redirect
     end
   end
   ```

4. **Test both happy path and edge cases**:
   ```ruby
   # Happy path
   test "valid product saves successfully" do
     product = Product.new(name: 'Test', price: 1000, category: categories(:category_one))
     assert product.save
   end

   # Edge case
   test "product with nil price fails validation" do
     product = Product.new(name: 'Test', price: nil, category: categories(:category_one))
     assert_not product.save
   end
   ```

---

## 🚀 CI/CD Integration

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:17
    steps:
      - uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - run: bin/rails db:setup
      - run: bin/rails test:all
      - run: rubocop
```

### Deployment Protection

- ❌ Deploy blocked if tests fail
- ❌ Deploy blocked if RuboCop fails
- ✅ Badge in README shows test status
- ✅ Coverage report uploaded to Codecov (optional)

---

## 📈 Long-Term Testing Goals (2026-2027)

### Performance Testing

- [ ] Add `benchmark-ips` gem for micro-benchmarks
- [ ] Set performance budgets (e.g., checkout < 2s)
- [ ] Add memory profiling with `memory_profiler`

### Load Testing

- [ ] Add `k6` or `Gatling` for load testing
- [ ] Test 100 concurrent users
- [ ] Test 1,000 orders/hour throughput

### Security Testing

- [ ] Add `brakeman` for static security analysis
- [ ] Add `bundler-audit` for dependency vulnerabilities
- [ ] Add penetration testing for payment flow

### Accessibility Testing

- [ ] Add `axe-core` for automated a11y testing
- [ ] Test with screen readers (NVDA, JAWS)
- [ ] WCAG 2.1 AA compliance

---

## 📚 References

- [Minitest Documentation](https://docs.seattlerb.org/minitest/)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [Stripe Testing Guide](https://stripe.com/docs/testing)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [SimpleCov Coverage Tool](https://github.com/simplecov-ruby/simplecov)

---

## 🔄 Continuous Improvement

This roadmap is a living document. Update it quarterly with:
- New test coverage metrics
- Lessons learned from production incidents
- New testing tools and practices
- Feedback from code reviews

**Next Review**: March 1, 2026
