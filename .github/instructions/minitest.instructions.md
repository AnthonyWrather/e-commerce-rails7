---
description: 'Minitest testing standards and best practices for Rails applications'
applyTo: '**/test/**/*.rb'
---

# Minitest Testing Instructions

Instructions for writing high-quality tests using Minitest, the default testing framework for Ruby on Rails applications.

## Project Context
- Minitest is the default Rails testing framework (not RSpec)
- Use fixtures for test data (YAML-based)
- Follow Rails testing conventions and best practices
- Aim for behavior-driven tests that validate functionality

## Test Types

### Model Tests (Unit Tests)
Location: `test/models/`
```ruby
class ProductTest < ActiveSupport::TestCase
  test "should validate presence of name" do
    product = Product.new(price: 1000)
    assert_not product.valid?
    assert_includes product.errors[:name], "can't be blank"
  end

  test "should have correct associations" do
    product = products(:one)
    assert_respond_to product, :category
    assert_respond_to product, :stocks
  end
end
```

### Controller Tests (Integration Tests)
Location: `test/controllers/`
```ruby
class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should redirect when not authenticated" do
    get admin_products_url
    assert_redirected_to new_admin_user_session_path
  end
end
```

### System Tests (Feature Tests)
Location: `test/system/`
```ruby
class CheckoutTest < ApplicationSystemTestCase
  test "user can complete checkout" do
    visit products_path
    click_on "Add to Cart"
    click_on "Checkout"
    assert_text "Order Complete"
  end
end
```

### Mailer Tests
Location: `test/mailers/`
```ruby
class OrderMailerTest < ActionMailer::TestCase
  test "order confirmation email" do
    order = orders(:one)
    email = OrderMailer.new_order_email(order)
    
    assert_equal ["admin@example.com"], email.from
    assert_equal [order.customer_email], email.to
    assert_match "Order Confirmation", email.subject
  end
end
```

## Testing Conventions

### Assertions
Use descriptive assertions that explain intent:
```ruby
# Good - Clear intent
assert_equal 3, products.count, "Expected 3 products after filter"
assert_not product.valid?, "Product without name should be invalid"
assert_includes errors[:email], "is invalid"

# Available assertions
assert                  # Truthiness
assert_not              # Falsiness
assert_equal            # Equality
assert_not_equal        # Inequality
assert_nil              # Nil check
assert_not_nil          # Not nil check
assert_raises           # Exception expected
assert_nothing_raised   # No exception expected
assert_includes         # Collection includes
assert_match            # Regex match
assert_respond_to       # Object responds to method
assert_difference       # Value changed
assert_no_difference    # Value unchanged
```

### Fixtures
Use YAML fixtures for test data:
```yaml
# test/fixtures/products.yml
one:
  name: Test Product
  price: 1000
  stock_level: 10
  category: one
  active: true

two:
  name: Another Product
  price: 2000
  stock_level: 5
  category: one
  active: false
```

Access fixtures in tests:
```ruby
test "fixture data is valid" do
  product = products(:one)
  assert product.valid?
  assert_equal "Test Product", product.name
end
```

### Setup and Teardown
```ruby
class OrderTest < ActiveSupport::TestCase
  setup do
    @order = orders(:one)
  end

  teardown do
    # Cleanup if needed
  end

  test "order has customer email" do
    assert_not_nil @order.customer_email
  end
end
```

### Testing with Authentication (Devise)
```ruby
class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in admin_users(:admin_user_one)
  end

  test "authenticated admin can access products" do
    get admin_products_url
    assert_response :success
  end
end
```

## Best Practices

### Test Organization
- One test file per class/concern
- Group related tests using descriptive names
- Test happy path and edge cases
- Test error conditions and validations

### Test Naming
- Use descriptive names that explain behavior
- Start with `test_` prefix or use `test "description"` syntax
- Describe expected outcome in name

```ruby
# Good naming
test "should create product with valid attributes"
test "should fail validation when price is negative"
test "should calculate total with VAT"

# Poor naming (avoid)
test "test1"
test "it works"
```

### Test Independence
- Each test should be independent
- Don't rely on test execution order
- Clean up state in teardown if needed
- Use transactions for database isolation (Rails default)

### Avoiding Test Smells
- Don't test implementation details
- Don't mock what you don't own
- Don't test private methods directly
- Keep tests fast (avoid unnecessary setup)

### Testing Controller Responses
```ruby
test "returns JSON response" do
  get products_url, as: :json
  assert_response :success
  assert_equal "application/json", response.content_type
  
  json = JSON.parse(response.body)
  assert_equal 3, json["products"].count
end
```

### Testing Database Changes
```ruby
test "creating product increases count" do
  assert_difference "Product.count", 1 do
    post products_url, params: {
      product: { name: "New", price: 1000 }
    }
  end
end

test "deleting product decreases count" do
  assert_difference "Product.count", -1 do
    delete product_url(products(:one))
  end
end
```

## Running Tests

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/product_test.rb

# Run specific test by line number
bin/rails test test/models/product_test.rb:10

# Run system tests
bin/rails test:system

# Run all tests including system tests
bin/rails test:all

# Run with verbose output
bin/rails test -v

# Run with specific seed
bin/rails test --seed 12345
```

## Coverage

Use SimpleCov for code coverage:
```ruby
# test/test_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
end
```

Aim for high coverage on critical code paths:
- Model validations and business logic
- Controller actions (especially create/update/destroy)
- Service objects and query objects
- Mailers
