# Test Suite Analysis - E-Commerce Rails 7

## Executive Summary

This Rails 7 application uses **Minitest** (not RSpec) as its testing framework. The test suite is comprehensive with 301 total tests, 749 assertions, and 8 skipped tests.

**Current Test Results:**
- **Unit/Integration Tests:** 285 runs, 730 assertions, 0 failures, 0 errors, 8 skips
- **System Tests:** 16 runs, 19 assertions, 0 failures, 0 errors
- **Total:** 301 tests, 749 assertions, 100% passing (excluding skips)

## Test Framework & Structure

### Framework: Minitest
- **Not RSpec** - Despite `rubocop-rspec` gem being present, the project uses Minitest
- Follows Rails default testing conventions
- Uses Capybara for system/integration tests
- Parallel test execution enabled

### Directory Structure
```
test/
├── channels/             # Action Cable tests
├── controllers/          # Controller integration tests
│   ├── admin/           # Admin namespace controllers
│   └── quantities/      # Calculator controllers
├── fixtures/            # Test data (YAML)
├── helpers/             # Helper tests
├── integration/         # Integration tests (Rack::Attack, Stripe)
├── mailers/             # Mailer tests
├── models/              # Model unit tests
│   └── admin/          # Admin namespace models
├── services/            # Service object tests
└── system/              # Capybara system tests
    └── admin/          # Admin UI tests
```

## Test Coverage by Layer

### 1. Model Tests (8 files)

**Comprehensive Coverage:**
- ✅ **Product** (`product_test.rb`) - 35 tests covering:
  - Name validations (required, not empty)
  - Price validations (required, numeric, integer, ≥0)
  - Stock level validations (numeric, integer, ≥0, nullable)
  - Shipping dimension validations (weight, length, width, height - all optional, integer, >0)
  - Category association validation
  - Scopes: `active`, `in_price_range(min, max)`

- ✅ **Order** (`order_test.rb`) - 25 tests covering:
  - Customer email validations (required, valid format)
  - Total validations (required, numeric, integer, ≥0)
  - Shipping cost validations (optional, numeric, integer, ≥0)
  - Address/name validations (required)
  - Scopes: `unfulfilled`, `fulfilled`, `recent(limit)`, `for_month(date)`

- ✅ **Stock** (`stock_test.rb`) - Comprehensive validation tests
- ✅ **OrderProduct** (`order_product_test.rb`) - Validation tests
- ⚠️ **Category** (`category_test.rb`) - Basic validation tests
- ⚠️ **AdminUser** (`admin_user_test.rb`) - Minimal coverage
- ⚠️ **ProductStock** (`product_stock_test.rb`) - Legacy model, minimal tests

**Test Pattern Example:**
```ruby
test 'should require price to be greater than or equal to zero' do
  @product.price = -1
  assert_not @product.valid?
  assert_includes @product.errors[:price], 'must be greater than or equal to 0'
end
```

### 2. Controller Tests (13 files)

**Admin Controllers:**
- `Admin::ProductsController` - Full CRUD operations + stock_level update test
- `Admin::CategoriesController` - Full CRUD operations
- `Admin::OrdersController` - Index, show, update (fulfill)
- `Admin::StocksController` - Nested resource CRUD
- `Admin::ReportsController` - Dashboard access
- `Admin::ImagesController` - Image deletion

**Public Controllers:**
- `CheckoutsController` - Stripe checkout initiation
- `ContactController` - Contact form submission
- `Quantities::*Controller` - Calculator business logic (3 controllers)

**Test Pattern:**
```ruby
test 'should update admin_product with stock_level' do
  new_stock_level = 42
  patch admin_product_url(@admin_product),
        params: { product: { name: @admin_product.name, price: @admin_product.price,
                             category_id: @admin_product.category_id, stock_level: new_stock_level } }
  assert_redirected_to edit_admin_product_url(@admin_product)
  @admin_product.reload
  assert_equal new_stock_level, @admin_product.stock_level
end
```

### 3. System Tests (4 files)

**Capybara-based UI Tests:**
- `Admin::ProductsTest` - Create, destroy products (update test commented out)
- `Admin::CategoriesTest` - Full CRUD via UI
- `Admin::OrdersTest` - Order fulfillment workflow
- `Admin::StocksTest` - Stock variant management
- `AdminLoginTest` - Authentication flow

**Browser Configuration:**
- Selenium with Chrome headless
- Screen size: 1400x1400
- Rack 3.x compatible (Capybara 3.40.0)

**Example:**
```ruby
test 'should create product' do
  visit admin_products_url
  click_on 'New product'

  check 'Active' if @admin_product.active
  select @admin_product.category.name, from: 'Category'
  fill_in 'Description', with: @admin_product.description
  fill_in 'Name', with: @admin_product.name
  fill_in 'Price', with: @admin_product.price
  click_on 'Create Product'

  assert_text 'Product was successfully created'
end
```

### 4. Service Object Tests (1 file)

**OrderProcessor** (`order_processor_test.rb`) - 16 tests covering:
- Order creation from Stripe session
- OrderProduct creation for line items
- Stock decrement (product vs variant)
- Address handling (shipping vs billing)
- Shipping description retrieval
- Error handling with custom exceptions
- Mock Stripe session and API responses

**Sophisticated Mocking:**
```ruby
class MockStripeSession
  def dig(*keys)
    result = session_data
    keys.each do |key|
      return nil if result.nil?
      result = result.is_a?(Hash) ? result[key] : nil
    end
    result
  end
end
```

### 5. Calculator Tests (3 files)

**Quantities Controllers:**
- `Quantities::AreaController` - 18 comprehensive tests
- `Quantities::DimensionsController` - Similar coverage
- `Quantities::MouldRectangleController` - Similar coverage

**Business Logic Tested:**
- Default values (material_width: 0.95, ratio: 1.6)
- Mat calculations with 15% wastage factor
- Material weight (kg) calculations
- Resin quantity calculations
- Catalyst (ml) calculations
- Total weight aggregation
- Edge cases (zero values, decimals, large values)
- All calculations rounded to 2 decimal places

**Example:**
```ruby
test 'should apply 15% wastage factor to mat and resin' do
  get '/quantities/area', params: { area: 10, layers: 1 }
  assert_response :success
  # Verify wastage factor of 1.15 (15%)
  mat_without_wastage = (10.0 * 1) / 0.95
  assert_equal (mat_without_wastage * 1.15).round(2), assigns(:mat_total)
end
```

### 6. Integration Tests (2 files)

**Rack::Attack** (`rack_attack_test.rb`) - 6 tests (SKIPPED by default):
- Global throttle: 300 requests per 5 minutes per IP
- Asset exclusion from throttling
- Admin login throttle: 5 attempts per 20 seconds (by IP and email)
- Contact form throttle: 5 submissions per minute per IP
- 429 status code verification

**Why Skipped:**
```ruby
setup do
  skip 'Rack::Attack middleware not loaded in test environment'
end
```
- Rack::Attack disabled in test environment by default
- Enable via `ENV['RACK_ATTACK_ENABLED']=true`

**Stripe Helpers** (`stripe_test_helpers_test.rb`) - Helper module tests

### 7. Mailer Tests (2 files)

- `OrderMailer` - Order confirmation emails
- `ContactMailer` - Contact form emails

## Test Patterns & Best Practices

### 1. Fixtures Over Factories
```ruby
setup do
  @admin_product = products(:product_one)
  @category = categories(:category_one)
end
```

### 2. Descriptive Test Names
```ruby
test 'should require price to be greater than or equal to zero'
test 'should apply 15% wastage factor to mat and resin'
test 'throttles admin login attempts by email'
```

### 3. Comprehensive Validation Testing
- Positive tests (valid data)
- Negative tests (invalid data)
- Edge cases (nil, zero, empty string)
- Boundary conditions

### 4. Controller Testing Pattern
```ruby
test 'should create admin_product' do
  assert_difference('Product.count') do
    post admin_products_url, params: { product: { ... } }
  end
  assert_redirected_to admin_product_url(Product.last)
end
```

### 5. Mock Objects for External Dependencies
- Stripe API calls mocked in OrderProcessor tests
- Mock sessions, products, and line items
- Dependency injection for testability

## Areas for Improvement

### 1. Test Coverage Gaps

**Missing/Minimal Tests:**
- ❌ **WebhooksController** - No tests for critical Stripe webhook handler
- ❌ **HomeController** - No tests
- ❌ **CategoriesController** - No tests (public-facing)
- ❌ **ProductsController** - No tests (public-facing)
- ❌ **CartsController** - No tests (critical cart logic)
- ⚠️ **AdminUser model** - Only basic tests
- ⚠️ **Category model** - Minimal validation tests
- ❌ **Active Storage** - No tests for image upload/processing

### 2. System Test Gaps

**Commented Out Test:**
```ruby
# TODO: Need to investigate this test fail.
# test 'should update Product' do
```
- Product update system test disabled
- Needs investigation and fix

**Missing System Tests:**
- Public product browsing
- Add to cart flow
- Checkout process (end-to-end)
- Quantity calculator UI

### 3. Integration Test Coverage

**Missing Integration Tests:**
- Complete checkout flow (cart → Stripe → webhook → order creation)
- Email delivery (currently using letter_opener_web)
- Image upload and processing
- VAT calculations in checkout

### 4. Security Testing

**Limited Security Tests:**
- Rack::Attack tests skipped by default
- No CSRF token tests
- No authorization tests (admin-only actions)
- No SQL injection prevention tests

### 5. Performance Testing

**No Performance Tests:**
- N+1 query detection
- Load testing for calculators
- Database query optimization verification

## Test Data Management

### Fixtures
- Located in `test/fixtures/`
- YAML-based test data
- Referenced via symbols: `products(:product_one)`

**Key Fixtures:**
- `products.yml` - 3+ product records
- `categories.yml` - Multiple categories
- `admin_users.yml` - Admin authentication
- `orders.yml` - Order records (fulfilled and unfulfilled)
- `stocks.yml` - Product variants

### Fixture Patterns
```yaml
product_one:
  name: "Test Product"
  price: 2000
  stock_level: 100
  active: true
  category: category_one
```

## Running Tests

### All Tests
```bash
bin/rails test              # Unit/integration only (285 tests)
bin/rails test:system       # System tests only (16 tests)
bin/rails test:all          # All tests (301 tests)
```

### Specific Tests
```bash
bin/rails test test/models/product_test.rb
bin/rails test test/models/product_test.rb:5
bin/rails test test/system/admin/products_test.rb
```

### With Coverage
```bash
COVERAGE=true bin/rails test
```

### Enable Rack::Attack Tests
```bash
RACK_ATTACK_ENABLED=true bin/rails test test/integration/rack_attack_test.rb
```

## Test Configuration

### Parallel Execution
```ruby
# test_helper.rb
parallelize(workers: :number_of_processors)
```

### System Test Setup
```ruby
# application_system_test_case.rb
driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
```

### Devise Integration
```ruby
class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
```

## Key Test Metrics

### Test Distribution
- Model tests: ~35% (comprehensive validations)
- Controller tests: ~30% (admin CRUD + calculators)
- System tests: ~5% (critical UI flows)
- Service tests: ~5% (OrderProcessor)
- Calculator tests: ~20% (business logic)
- Integration tests: ~5% (skipped by default)

### Test Quality Indicators
✅ **Strengths:**
- Zero failures in main test suite
- Comprehensive model validation coverage
- Sophisticated mocking for external dependencies
- Calculator business logic thoroughly tested
- Descriptive test names
- Good use of fixtures

⚠️ **Weaknesses:**
- Critical controllers untested (Webhooks, Cart, public Product/Category)
- Limited integration test coverage
- Security tests skipped by default
- No performance tests
- One system test commented out (needs fix)
- No end-to-end checkout flow tests

## Recommendations

### Priority 1: Critical Coverage
1. **Add WebhooksController tests** - Critical for order creation
2. **Add CartController tests** - Critical user flow
3. **Fix commented-out system test** - Product update
4. **Add end-to-end checkout tests** - Full user journey

### Priority 2: Security & Integration
1. Enable and run Rack::Attack tests in CI
2. Add authorization tests for admin routes
3. Add CSRF protection tests
4. Test image upload/processing with Active Storage

### Priority 3: Performance & Quality
1. Add N+1 query detection (Bullet gem)
2. Add simplecov for coverage reporting
3. Add load tests for calculators
4. Test email delivery (not just templates)

### Priority 4: Documentation
1. Document how to run specific test suites
2. Add test data seeding guide
3. Document mock/stub patterns
4. Create testing contribution guidelines

## Conclusion

The test suite is **solid and well-structured** with comprehensive model validation coverage and good calculator business logic testing. However, there are **critical gaps** in controller and integration tests, particularly for public-facing features and the checkout flow.

**Overall Grade: B+**
- Excellent model and validation testing
- Good service object testing
- Needs critical controller coverage
- Needs integration test expansion
- Security tests need to be enabled

**Next Steps:**
1. Add WebhooksController tests immediately
2. Add CartController and public controller tests
3. Create end-to-end checkout flow tests
4. Enable Rack::Attack tests in CI
5. Add coverage reporting with simplecov
