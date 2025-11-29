# Sprint Plan 01: Critical Security Fixes & Core Improvements

**Sprint Duration**: 2 weeks
**Sprint Goal**: Address critical security vulnerabilities and implement essential missing features while improving code quality and test coverage.

---

## Executive Summary

This sprint focuses on addressing **critical security issues** identified in the comprehensive codebase analysis, implementing **missing core functionality** (contact form), and establishing a foundation for better **code quality** through testing and refactoring.

### Key Objectives
1. ✅ Fix critical security vulnerabilities (LetterOpener, rate limiting, CSP)
2. ✅ Implement functional contact form with email delivery
3. ✅ Add comprehensive webhook testing
4. ✅ Refactor webhook logic into service object
5. ✅ Improve error logging and monitoring

---

## Week 1: Critical Security & Infrastructure

### Day 1-2: Security Lockdown (9 Story Points)

#### Task 1.1: Fix LetterOpenerWeb Production Exposure
**Priority**: CRITICAL
**Story Points**: 1
**Assignee**: TBD

**Description**: LetterOpenerWeb is currently mounted in production at `/letter_opener`, exposing all customer emails and order details publicly.

**Implementation**:
```ruby
# config/routes.rb
# BEFORE:
mount LetterOpenerWeb::Engine, at: '/letter_opener'

# AFTER:
if Rails.env.development?
  mount LetterOpenerWeb::Engine, at: '/letter_opener'
end
```

**Acceptance Criteria**:
- [ ] Letter opener only accessible in development environment
- [ ] Production deployment verified - route returns 404
- [ ] No email data exposed via public URL
- [ ] Staging environment tested

**Testing**:
```bash
# In production/staging
curl https://shop.cariana.tech/letter_opener
# Should return 404
```

---

#### Task 1.2: Implement Rate Limiting with Rack::Attack
**Priority**: CRITICAL
**Story Points**: 3
**Assignee**: TBD

**Description**: Application has no rate limiting, making it vulnerable to brute force attacks, spam, and DDoS.

**Implementation**:
```ruby
# Gemfile
gem 'rack-attack'

# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle all requests by IP (300 requests/5 minutes)
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Throttle admin login attempts
  throttle('admin_login/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/admin_users/sign_in' && req.post?
  end

  # Throttle checkout attempts
  throttle('checkout/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/checkout' && req.post?
  end

  # Throttle contact form submissions
  throttle('contact/ip', limit: 5, period: 1.minute) do |req|
    req.ip if req.path == '/contact' && req.post?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    [429, {'Content-Type' => 'text/plain'}, ['Too many requests. Please try again later.']]
  end
end

# config/application.rb
config.middleware.use Rack::Attack
```

**Acceptance Criteria**:
- [ ] Rate limiting active on all forms
- [ ] Admin login brute force protection working (max 5 attempts/20s)
- [ ] Checkout rate limiting prevents abuse (max 10/minute)
- [ ] Contact form rate limiting active (max 5/minute)
- [ ] Throttled requests receive 429 status
- [ ] Test with automated requests to verify limits
- [ ] Monitor logs for false positives
- [ ] Documentation updated with rate limit details

**Testing**:
```bash
# Test admin login rate limiting
for i in {1..10}; do
  curl -X POST https://shop.cariana.tech/admin_users/sign_in \
    -d "admin_user[email]=test@test.com&admin_user[password]=wrong"
done
# Should see 429 after 5 requests
```

---

#### Task 1.3: Enable Content Security Policy
**Priority**: HIGH
**Story Points**: 5
**Assignee**: TBD

**Description**: No CSP headers are configured, leaving the application vulnerable to XSS attacks.

**Implementation**:
```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, 'via.placeholder.com'
    policy.object_src  :none
    policy.script_src  :self, :https, 'www.googletagmanager.com', 'www.google-analytics.com'
    policy.style_src   :self, :https, :unsafe_inline  # Temporary for Tailwind
    policy.connect_src :self, :https, 'www.google-analytics.com'
  end

  # Generate nonce for inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src)

  # Report violations to logging
  config.content_security_policy_report_only = true  # Start in report-only mode
end
```

**Acceptance Criteria**:
- [ ] CSP headers active in production
- [ ] No console errors on any page (home, products, admin, checkout)
- [ ] Google Analytics still functioning
- [ ] All images loading correctly
- [ ] Font Awesome icons displaying
- [ ] Tailwind styles working
- [ ] Report violations logged to Rails logger
- [ ] After testing period, switch to enforcement mode

**Testing Checklist**:
- [ ] Home page loads without CSP violations
- [ ] Product pages display correctly
- [ ] Admin dashboard renders properly
- [ ] Cart functionality works
- [ ] Checkout flow completes
- [ ] Contact form submits
- [ ] Quantity calculators function

---

### Day 3-4: Contact Form Implementation (7 Story Points)

#### Task 1.4: Implement Functional Contact Form
**Priority**: HIGH
**Story Points**: 5
**Assignee**: TBD

**Description**: Contact form currently shows success message but doesn't send any email or store data.

**Current State** (`app/controllers/contact_controller.rb`):
```ruby
def create
  @first_name = params[:contact_form][:first_name]
  @last_name = params[:contact_form][:last_name]
  @email = params[:contact_form][:email]
  @message = params[:contact_form][:message]

  flash[:success] = 'Your message has been sent successfully.'
  redirect_to :contact
end
```

**Implementation**:

**Step 1**: Create Contact Mailer
```ruby
# app/mailers/contact_mailer.rb
class ContactMailer < ApplicationMailer
  def contact_email(contact_params)
    @first_name = contact_params[:first_name]
    @last_name = contact_params[:last_name]
    @email = contact_params[:email]
    @message = contact_params[:message]

    mail(
      to: ENV.fetch('ADMIN_EMAIL', 'admin@cariana.tech'),
      from: 'noreply@cariana.tech',
      reply_to: @email,
      subject: "Contact Form: #{@first_name} #{@last_name}"
    )
  end
end
```

**Step 2**: Create Email Template
```erb
<!-- app/views/contact_mailer/contact_email.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h2>New Contact Form Submission</h2>

    <p><strong>Name:</strong> <%= @first_name %> <%= @last_name %></p>
    <p><strong>Email:</strong> <%= @email %></p>

    <h3>Message:</h3>
    <p><%= simple_format(@message) %></p>

    <hr>
    <p style="color: #666; font-size: 12px;">
      This email was sent from the contact form at shop.cariana.tech
    </p>
  </body>
</html>
```

**Step 3**: Update Controller with Validation
```ruby
# app/controllers/contact_controller.rb
class ContactController < ApplicationController
  def index; end

  def create
    @contact_params = contact_form_params

    if valid_contact?(@contact_params)
      ContactMailer.contact_email(@contact_params).deliver_later
      flash[:success] = 'Your message has been sent successfully.'
      redirect_to contact_path
    else
      flash[:error] = 'Please fill in all fields correctly.'
      redirect_to contact_path
    end
  end

  private

  def contact_form_params
    params.require(:contact_form).permit(:first_name, :last_name, :email, :message)
  end

  def valid_contact?(params)
    params[:first_name].present? &&
    params[:last_name].present? &&
    params[:email].present? &&
    params[:message].present? &&
    valid_email?(params[:email])
  end

  def valid_email?(email)
    email.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
```

**Acceptance Criteria**:
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

**Environment Configuration**:
```bash
# .env.example (add this)
ADMIN_EMAIL=admin@cariana.tech
```

---

#### Task 1.5: Add Contact Form Tests
**Priority**: HIGH
**Story Points**: 2
**Assignee**: TBD

**Description**: Contact controller has no tests. Need comprehensive test coverage.

**Implementation**:
```ruby
# test/controllers/contact_controller_test.rb
require 'test_helper'

class ContactControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get contact_url
    assert_response :success
  end

  test 'should send contact email with valid data' do
    assert_enqueued_emails 1 do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john@example.com',
          message: 'Test message from automated test'
        }
      }
    end

    assert_redirected_to contact_path
    assert_equal 'Your message has been sent successfully.', flash[:success]
  end

  test 'should reject submission with missing first name' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: '',
          last_name: 'Doe',
          email: 'john@example.com',
          message: 'Test'
        }
      }
    end

    assert_redirected_to contact_path
    assert_equal 'Please fill in all fields correctly.', flash[:error]
  end

  test 'should reject submission with missing email' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: '',
          message: 'Test'
        }
      }
    end

    assert_equal 'Please fill in all fields correctly.', flash[:error]
  end

  test 'should reject invalid email format' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'invalid-email',
          message: 'Test'
        }
      }
    end

    assert_equal 'Please fill in all fields correctly.', flash[:error]
  end

  test 'should reject submission with missing message' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john@example.com',
          message: ''
        }
      }
    end

    assert_equal 'Please fill in all fields correctly.', flash[:error]
  end
end

# test/mailers/contact_mailer_test.rb
require 'test_helper'

class ContactMailerTest < ActionMailer::TestCase
  test 'contact_email' do
    contact_params = {
      first_name: 'John',
      last_name: 'Doe',
      email: 'john@example.com',
      message: 'This is a test message'
    }

    email = ContactMailer.contact_email(contact_params)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ENV.fetch('ADMIN_EMAIL', 'admin@cariana.tech')], email.to
    assert_equal 'Contact Form: John Doe', email.subject
    assert_equal ['john@example.com'], email.reply_to
    assert_match 'This is a test message', email.body.encoded
  end
end
```

**Acceptance Criteria**:
- [ ] All contact controller tests passing
- [ ] All contact mailer tests passing
- [ ] Tests verify email delivery
- [ ] Tests verify validation logic
- [ ] Tests verify error messages
- [ ] Code coverage >90% for contact controller

---

### Day 5: Webhook Testing (10 Story Points)

#### Task 1.6: Add Comprehensive Webhook Tests
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: WebhooksController has zero tests despite being the most critical code path (order creation, stock updates, email sending).

**Implementation**:

**Step 1**: Create Stripe Test Fixtures
```json
// test/fixtures/files/stripe/checkout_completed.json
{
  "id": "evt_test_webhook",
  "type": "checkout.session.completed",
  "data": {
    "object": {
      "id": "cs_test_123",
      "amount_total": 15000,
      "payment_status": "paid",
      "payment_intent": "pi_test_123",
      "customer_details": {
        "email": "test@example.com",
        "name": "Test Customer",
        "phone": "+44123456789",
        "address": {
          "line1": "123 Test St",
          "line2": "",
          "city": "London",
          "state": "",
          "postal_code": "SW1A 1AA",
          "country": "GB"
        }
      },
      "shipping_details": {
        "name": "Test Customer",
        "address": {
          "line1": "123 Test St",
          "line2": "",
          "city": "London",
          "state": "",
          "postal_code": "SW1A 1AA",
          "country": "GB"
        }
      },
      "total_details": {
        "amount_shipping": 500
      },
      "line_items": {
        "data": [
          {
            "quantity": 2,
            "amount_total": 10000,
            "description": "Test Product",
            "metadata": {
              "product_id": "1",
              "size": "Large",
              "product_price": "5000"
            }
          }
        ]
      }
    }
  }
}
```

**Step 2**: Create Webhook Tests
```ruby
# test/controllers/webhooks_controller_test.rb
require 'test_helper'

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:product_one)
    @product.update(stock_level: 100)
  end

  test 'should create order from valid Stripe webhook' do
    payload = load_stripe_fixture('checkout_completed')
    sig_header = generate_stripe_signature(payload.to_json)

    assert_difference('Order.count', 1) do
      assert_difference('OrderProduct.count', 1) do
        post webhooks_url,
          params: payload.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Stripe-Signature' => sig_header
          }
      end
    end

    assert_response :success

    order = Order.last
    assert_equal 'test@example.com', order.customer_email
    assert_equal 15000, order.total
    assert_equal 'paid', order.payment_status
    assert_equal 'pi_test_123', order.payment_id
    assert_equal 500, order.shipping_cost
    assert_not order.fulfilled
  end

  test 'should create order products with correct data' do
    payload = load_stripe_fixture('checkout_completed')
    sig_header = generate_stripe_signature(payload.to_json)

    post webhooks_url,
      params: payload.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Stripe-Signature' => sig_header
      }

    order = Order.last
    order_product = order.order_products.first

    assert_equal @product.id, order_product.product_id
    assert_equal 'Large', order_product.size
    assert_equal 2, order_product.quantity
    assert_equal 5000, order_product.price
  end

  test 'should decrement stock levels after order creation' do
    payload = load_stripe_fixture('checkout_completed')
    sig_header = generate_stripe_signature(payload.to_json)

    initial_stock = @product.stock_level

    post webhooks_url,
      params: payload.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Stripe-Signature' => sig_header
      }

    @product.reload
    assert_equal initial_stock - 2, @product.stock_level
  end

  test 'should queue confirmation email after order creation' do
    payload = load_stripe_fixture('checkout_completed')
    sig_header = generate_stripe_signature(payload.to_json)

    assert_enqueued_emails 1 do
      post webhooks_url,
        params: payload.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Stripe-Signature' => sig_header
        }
    end
  end

  test 'should reject webhook with invalid signature' do
    payload = load_stripe_fixture('checkout_completed')

    assert_no_difference('Order.count') do
      post webhooks_url,
        params: payload.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Stripe-Signature' => 'invalid_signature'
        }
    end

    assert_response :bad_request
  end

  test 'should handle webhook with missing signature' do
    payload = load_stripe_fixture('checkout_completed')

    assert_no_difference('Order.count') do
      post webhooks_url,
        params: payload.to_json,
        headers: { 'Content-Type' => 'application/json' }
    end

    assert_response :bad_request
  end

  test 'should log unhandled event types' do
    payload = {
      id: 'evt_test',
      type: 'customer.created',
      data: { object: {} }
    }
    sig_header = generate_stripe_signature(payload.to_json)

    assert_no_difference('Order.count') do
      post webhooks_url,
        params: payload.to_json,
        headers: {
          'Content-Type' => 'application/json',
          'Stripe-Signature' => sig_header
        }
    end

    assert_response :success
  end

  private

  def load_stripe_fixture(name)
    JSON.parse(file_fixture("stripe/#{name}.json").read)
  end

  def generate_stripe_signature(payload)
    timestamp = Time.now.to_i
    secret = Rails.application.credentials.dig(:stripe, :webhook_key) || ENV['STRIPE_WEBHOOK_KEY']

    signature = Stripe::Webhook::Signature.compute_signature(
      timestamp,
      payload,
      secret
    )

    "t=#{timestamp},v1=#{signature}"
  end
end
```

**Acceptance Criteria**:
- [ ] Test valid webhook creates order ✓
- [ ] Test order has correct customer details ✓
- [ ] Test order products created with correct data ✓
- [ ] Test stock levels decremented ✓
- [ ] Test confirmation email queued ✓
- [ ] Test invalid signature rejected ✓
- [ ] Test missing signature rejected ✓
- [ ] Test unhandled event types logged ✓
- [ ] All tests passing
- [ ] Code coverage >80% for webhooks controller

---

#### Task 1.7: Add Webhook Integration Test Helper
**Priority**: MEDIUM
**Story Points**: 2
**Assignee**: TBD

**Description**: Create reusable helper for Stripe webhook testing to use in future tests.

**Implementation**:
```ruby
# test/support/stripe_test_helpers.rb
module StripeTestHelpers
  def load_stripe_fixture(name)
    JSON.parse(file_fixture("stripe/#{name}.json").read)
  end

  def generate_stripe_signature(payload)
    timestamp = Time.now.to_i
    secret = Rails.application.credentials.dig(:stripe, :webhook_key) ||
             ENV['STRIPE_WEBHOOK_KEY'] ||
             'whsec_test_secret'

    signature = Stripe::Webhook::Signature.compute_signature(
      timestamp,
      payload.is_a?(String) ? payload : payload.to_json,
      secret
    )

    "t=#{timestamp},v1=#{signature}"
  end

  def post_stripe_webhook(event_type, data = {})
    payload = {
      id: "evt_test_#{SecureRandom.hex(8)}",
      type: event_type,
      data: { object: data }
    }

    post webhooks_url,
      params: payload.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Stripe-Signature' => generate_stripe_signature(payload.to_json)
      }
  end
end

# test/test_helper.rb
class ActionDispatch::IntegrationTest
  include StripeTestHelpers
end
```

**Acceptance Criteria**:
- [ ] Helper methods available in all integration tests
- [ ] Signature generation reusable
- [ ] Fixture loading simplified
- [ ] Documentation added for usage

---

## Week 2: Refactoring & Architecture

### Day 6-7: Extract Webhook Logic (8 Story Points)

#### Task 2.1: Create OrderProcessor Service Object
**Priority**: HIGH
**Story Points**: 8
**Assignee**: TBD

**Description**: WebhooksController#stripe is 90+ lines of complex logic. Extract to service object following Single Responsibility Principle.

**Current State**: All logic in controller
**Target State**: Thin controller, service handles business logic

**Implementation**:

**Step 1**: Create Service Object
```ruby
# app/services/order_processor.rb
class OrderProcessor
  attr_reader :session, :errors, :order

  def initialize(stripe_session)
    @session = stripe_session
    @errors = []
    @order = nil
  end

  def process
    return false unless valid_session?

    ActiveRecord::Base.transaction do
      create_order
      create_order_products
      decrement_stock_levels
      send_confirmation_email
    end

    Rails.logger.info("Order processed successfully", {
      order_id: @order.id,
      session_id: session.id,
      customer_email: @order.customer_email
    })

    true
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error("Order processing failed", {
      error: e.message,
      backtrace: e.backtrace[0..5],
      session_id: session&.id
    })
    Honeybadger.notify(e, context: {
      session_id: session&.id,
      customer_email: session&.customer_details&.email
    })
    false
  end

  private

  def valid_session?
    if session.blank?
      @errors << "Session is blank"
      return false
    end

    if session.payment_status != 'paid'
      @errors << "Payment status is not 'paid': #{session.payment_status}"
      return false
    end

    true
  end

  def create_order
    @order = Order.create!(
      customer_email: session.customer_details.email,
      fulfilled: false,
      total: session.amount_total,
      address: build_address(session.shipping_details&.address),
      name: session.shipping_details&.name || session.customer_details.name,
      phone: session.customer_details.phone,
      billing_name: session.customer_details.name,
      billing_address: build_address(session.customer_details.address),
      payment_status: session.payment_status,
      payment_id: session.payment_intent,
      shipping_cost: session.total_details&.amount_shipping || 0,
      shipping_id: session.shipping_options&.first&.shipping_rate,
      shipping_description: session.shipping_options&.first&.shipping_amount
    )

    Rails.logger.info("Order created", {
      order_id: @order.id,
      customer_email: @order.customer_email,
      total: @order.total
    })
  end

  def create_order_products
    line_items = fetch_line_items

    line_items.each do |line_item|
      order_product = OrderProduct.create!(
        order: @order,
        product_id: line_item.metadata.product_id,
        size: line_item.metadata.size,
        quantity: line_item.quantity,
        price: line_item.amount_total / line_item.quantity
      )

      Rails.logger.debug("Order product created", {
        order_product_id: order_product.id,
        product_id: order_product.product_id,
        quantity: order_product.quantity
      })
    end
  end

  def fetch_line_items
    # Line items may or may not be expanded in the session
    if session.line_items.is_a?(Array)
      session.line_items
    else
      session.line_items.data
    end
  end

  def decrement_stock_levels
    @order.order_products.each do |order_product|
      decrement_product_stock(order_product)
    end
  end

  def decrement_product_stock(order_product)
    if order_product.size.present?
      # Variant stock (Stock model)
      stock = Stock.find_by(
        product_id: order_product.product_id,
        size: order_product.size
      )

      if stock
        stock.decrement!(:stock_level, order_product.quantity)
        Rails.logger.info("Stock decremented", {
          stock_id: stock.id,
          size: stock.size,
          quantity: order_product.quantity,
          remaining: stock.stock_level
        })
      else
        Rails.logger.warn("Stock not found for variant", {
          product_id: order_product.product_id,
          size: order_product.size
        })
      end
    else
      # Product stock (Product model)
      product = order_product.product
      product.decrement!(:stock_level, order_product.quantity)
      Rails.logger.info("Product stock decremented", {
        product_id: product.id,
        quantity: order_product.quantity,
        remaining: product.stock_level
      })
    end
  end

  def send_confirmation_email
    OrderMailer.new_order_email(@order).deliver_later
    Rails.logger.info("Confirmation email queued", {
      order_id: @order.id,
      customer_email: @order.customer_email
    })
  end

  def build_address(address_details)
    return '' unless address_details

    [
      address_details.line1,
      address_details.line2,
      address_details.city,
      address_details.state,
      address_details.postal_code,
      address_details.country
    ].compact.reject(&:blank?).join(', ')
  end
end
```

**Step 2**: Refactor Controller
```ruby
# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    event = verify_stripe_event
    return head :bad_request unless event

    handle_stripe_event(event)
  end

  private

  def verify_stripe_event
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']

    Stripe::Webhook.construct_event(
      payload,
      sig_header,
      Rails.application.credentials.dig(:stripe, :webhook_key) || ENV['STRIPE_WEBHOOK_KEY']
    )
  rescue Stripe::SignatureVerificationError => e
    Rails.logger.warn("Webhook signature verification failed", {
      ip: request.remote_ip,
      request_id: request.request_id,
      error: e.message
    })
    Honeybadger.notify(e, context: {
      ip: request.remote_ip,
      request_id: request.request_id
    })
    nil
  rescue JSON::ParserError => e
    Rails.logger.error("Webhook JSON parsing failed", {
      error: e.message,
      request_id: request.request_id
    })
    Honeybadger.notify(e)
    nil
  end

  def handle_stripe_event(event)
    Rails.logger.info("Stripe webhook received", {
      event_type: event.type,
      event_id: event.id,
      request_id: request.request_id
    })

    case event.type
    when 'checkout.session.completed'
      process_checkout_session(event)
    else
      Rails.logger.info("Unhandled Stripe event type", {
        event_type: event.type,
        event_id: event.id
      })
      render json: { message: 'success' }
    end
  rescue StandardError => e
    Rails.logger.error("Webhook processing failed", {
      error: e.message,
      backtrace: e.backtrace[0..5],
      event_id: event&.id,
      request_id: request.request_id
    })
    Honeybadger.notify(e, context: {
      event_id: event&.id,
      event_type: event&.type
    })
    head :internal_server_error
  end

  def process_checkout_session(event)
    session = Stripe::Checkout::Session.retrieve({
      id: event.data.object.id,
      expand: ['line_items']
    })

    processor = OrderProcessor.new(session)

    if processor.process
      render json: { message: 'success' }
    else
      Rails.logger.error("Order processing failed", {
        errors: processor.errors,
        session_id: session.id
      })
      head :internal_server_error
    end
  end
end
```

**Acceptance Criteria**:
- [ ] Webhook controller under 50 lines
- [ ] All business logic in OrderProcessor
- [ ] Service object fully tested
- [ ] Controller tests updated and passing
- [ ] Error handling improved with logging
- [ ] Honeybadger notifications include context
- [ ] Transaction rollback on any failure
- [ ] All existing webhook tests still passing
- [ ] Code more maintainable and readable

**Benefits**:
- ✅ Single Responsibility: Controller handles HTTP, Service handles business logic
- ✅ Testability: Service can be tested independently
- ✅ Reusability: Service can be called from console, rake tasks, etc.
- ✅ Error Handling: Centralized error handling and logging
- ✅ Maintainability: Easier to understand and modify

---

### Day 8-9: Add Model Scopes (5 Story Points)

#### Task 2.2: Implement Model Scopes
**Priority**: MEDIUM
**Story Points**: 3
**Assignee**: TBD

**Description**: No scopes defined in models. Business logic repeated across controllers.

**Implementation**:

```ruby
# app/models/order.rb
class Order < ApplicationRecord
  has_many :order_products, dependent: :destroy

  # Scopes
  scope :unfulfilled, -> { where(fulfilled: false) }
  scope :fulfilled, -> { where(fulfilled: true) }
  scope :for_month, ->(date = Date.today) {
    where(created_at: date.beginning_of_month..date.end_of_month)
  }
  scope :for_date_range, ->(start_date, end_date) {
    where(created_at: start_date..end_date)
  }
  scope :recent, ->(limit = 5) { order(created_at: :desc).limit(limit) }
  scope :with_email, ->(email) { where(customer_email: email) }
end

# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category
  has_many :stocks, dependent: :destroy
  has_many :order_products, dependent: :destroy
  has_many_attached :images

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :in_price_range, ->(min, max) { where(price: min..max) }
  scope :with_stock, -> { where('stock_level > ?', 0) }
  scope :out_of_stock, -> { where(stock_level: 0) }
  scope :low_stock, ->(threshold = 10) { where('stock_level < ? AND stock_level > 0', threshold) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :search_by_name, ->(query) { where('name ILIKE ?', "%#{query}%") }
end

# app/models/category.rb
class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  has_one_attached :image

  # Scopes
  scope :with_active_products, -> {
    joins(:products).where(products: { active: true }).distinct
  }
  scope :with_products_in_stock, -> {
    joins(:products).where('products.stock_level > 0').distinct
  }
end

# app/models/stock.rb
class Stock < ApplicationRecord
  belongs_to :product

  # Scopes
  scope :in_stock, -> { where('stock_level > 0') }
  scope :out_of_stock, -> { where(stock_level: 0) }
  scope :low_stock, ->(threshold = 10) { where('stock_level < ? AND stock_level > 0', threshold) }
  scope :for_size, ->(size) { where(size: size) }
end
```

**Acceptance Criteria**:
- [ ] Scopes defined on all models
- [ ] Scopes tested in model tests
- [ ] Scopes chainable (e.g., `Product.active.with_stock`)
- [ ] No breaking changes to existing queries

---

#### Task 2.3: Refactor Controllers to Use Scopes
**Priority**: MEDIUM
**Story Points**: 2
**Assignee**: TBD

**Description**: Update controllers to use new scopes instead of inline queries.

**Implementation**:

```ruby
# app/controllers/admin_controller.rb
# BEFORE:
@orders = Order.where(fulfilled: false).order(created_at: :desc).limit(5)
@monthly_stats = {
  sales: Order.where(created_at: Time.now.beginning_of_month..Time.now.end_of_month).count
}

# AFTER:
@orders = Order.unfulfilled.recent(5)
@monthly_stats = {
  sales: Order.for_month.count,
  items: OrderProduct.joins(:order).merge(Order.for_month).sum(:quantity),
  revenue: Order.for_month.sum(:total)&.round(),
  avg_sale: Order.for_month.average(:total)&.round()
}
```

```ruby
# app/controllers/admin/orders_controller.rb
# BEFORE:
@not_fulfilled_pagy, @not_fulfilled_orders = pagy(
  Order.where(fulfilled: false).order(created_at: :asc)
)

# AFTER:
@not_fulfilled_pagy, @not_fulfilled_orders = pagy(
  Order.unfulfilled.order(created_at: :asc)
)
```

```ruby
# app/controllers/categories_controller.rb
# BEFORE:
@products = @category.products
@products = @products.where(active: true)
@products = @products.where('price <= ?', params[:max]) if params[:max].present?

# AFTER:
@products = @category.products.active
@products = @products.in_price_range(params[:min], params[:max]) if params[:min].present? || params[:max].present?
```

**Acceptance Criteria**:
- [ ] All controllers refactored
- [ ] No SQL changes (same queries, cleaner code)
- [ ] All tests still passing
- [ ] Code more readable and maintainable

---

### Day 10: Error Logging & Monitoring (5 Story Points)

#### Task 2.4: Implement Comprehensive Error Logging
**Priority**: MEDIUM
**Story Points**: 5
**Assignee**: TBD

**Description**: Only 1 `Rails.logger` call exists. No structured logging. Difficult to debug production issues.

**Implementation**:

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :log_request_info

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from StandardError, with: :internal_server_error

  private

  def log_request_info
    Rails.logger.info("Request started", {
      request_id: request.request_id,
      method: request.method,
      path: request.path,
      ip: request.remote_ip,
      user_agent: request.user_agent,
      params: filtered_params
    })
  end

  def filtered_params
    params.except(:controller, :action, :authenticity_token, :password, :password_confirmation)
  end

  def record_not_found(exception)
    Rails.logger.warn("Record not found", {
      request_id: request.request_id,
      exception: exception.message,
      model: exception.model,
      backtrace: exception.backtrace[0..2]
    })

    respond_to do |format|
      format.html { render file: 'public/404.html', status: :not_found, layout: false }
      format.json { render json: { error: 'Not found' }, status: :not_found }
    end
  end

  def record_invalid(exception)
    Rails.logger.error("Validation failed", {
      request_id: request.request_id,
      model: exception.record.class.name,
      errors: exception.record.errors.full_messages,
      backtrace: exception.backtrace[0..2]
    })

    Honeybadger.notify(exception, context: {
      model: exception.record.class.name,
      errors: exception.record.errors.full_messages
    })

    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: 'Validation failed' }
      format.json { render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity }
    end
  end

  def internal_server_error(exception)
    Rails.logger.error("Internal server error", {
      request_id: request.request_id,
      exception: exception.class.name,
      message: exception.message,
      backtrace: exception.backtrace[0..10]
    })

    Honeybadger.notify(exception, context: {
      request_id: request.request_id,
      params: filtered_params
    })

    respond_to do |format|
      format.html { render file: 'public/500.html', status: :internal_server_error, layout: false }
      format.json { render json: { error: 'Internal server error' }, status: :internal_server_error }
    end
  end
end
```

```ruby
# app/controllers/checkouts_controller.rb
def create
  Rails.logger.info("Checkout initiated", {
    request_id: request.request_id,
    cart_items: cart.size
  })

  # ... existing code ...

  Rails.logger.info("Stripe session created", {
    request_id: request.request_id,
    session_id: session.id,
    amount_total: session.amount_total
  })
rescue Stripe::StripeError => e
  Rails.logger.error("Stripe error during checkout", {
    request_id: request.request_id,
    error: e.message,
    error_type: e.class.name
  })
  Honeybadger.notify(e)
  render json: { error: e.message }, status: :internal_server_error
end
```

**Acceptance Criteria**:
- [ ] Structured logging implemented
- [ ] All errors logged with context (request ID, params, etc.)
- [ ] Request ID tracked throughout request lifecycle
- [ ] Honeybadger receives full error context
- [ ] Custom error pages for 404/500
- [ ] Logs are JSON-formatted for easy parsing
- [ ] Sensitive data filtered from logs

---

## Sprint Deliverables

### Definition of Done
- [ ] All code reviewed and approved
- [ ] All tests passing (247+ tests, 0 failures)
- [ ] RuboCop clean (0 offenses)
- [ ] Documentation updated
- [ ] Deployed to staging and tested
- [ ] Production deployment successful
- [ ] Monitoring confirms no regressions

### Must-Have (Critical)
- [ ] LetterOpenerWeb restricted to development ✓
- [ ] Rate limiting active and tested ✓
- [ ] CSP enabled without breaking functionality ✓
- [ ] Contact form sends emails ✓
- [ ] Contact form has validation ✓
- [ ] Webhook has comprehensive tests ✓
- [ ] OrderProcessor service extracted ✓

### Should-Have (High Priority)
- [ ] Model scopes implemented ✓
- [ ] Controllers refactored to use scopes ✓
- [ ] Comprehensive error logging ✓
- [ ] Custom error pages created

### Nice-to-Have (Medium Priority)
- [ ] Performance monitoring baseline
- [ ] Security audit report
- [ ] Updated deployment documentation

---

## Story Point Summary

| Category | Points | Percentage |
|----------|--------|------------|
| Critical Security | 9 | 21% |
| Contact Form | 7 | 17% |
| Testing | 10 | 24% |
| Refactoring | 13 | 31% |
| Logging | 5 | 12% |
| **Total** | **42** | **100%** |

**Velocity Target**: 40-45 story points for 2-week sprint (team of 2-3 developers)

---

## Risk Management

### High Risk Items

#### 1. CSP Implementation May Break Functionality
- **Impact**: High
- **Probability**: Medium
- **Mitigation**:
  - Start with report-only mode
  - Test all pages thoroughly before enforcement
  - Monitor console for violations
  - Have rollback plan ready
  - Test in staging first

#### 2. Webhook Refactoring Affects Critical Payment Flow
- **Impact**: Critical
- **Probability**: Low
- **Mitigation**:
  - Extensive testing with Stripe test mode
  - Review all test fixtures
  - Gradual rollout with feature flag
  - Monitor Honeybadger for errors
  - Keep backup of old code
  - Test with real Stripe webhooks in staging

#### 3. Rate Limiting Blocks Legitimate Users
- **Impact**: High
- **Probability**: Low
- **Mitigation**:
  - Conservative limits initially
  - Monitor logs for false positives
  - Implement whitelist for known IPs
  - Add admin dashboard to view throttled requests
  - Adjust limits based on real traffic data

### Testing Strategy

#### Unit Tests
- All new code has >80% coverage
- Models, services, mailers fully tested
- Edge cases covered

#### Integration Tests
- Webhook flow end-to-end
- Contact form submission
- Order creation and stock updates
- Email delivery

#### Manual Testing Checklist
- [ ] Test contact form in development
- [ ] Test contact form in staging
- [ ] Verify rate limiting with multiple requests
- [ ] Check CSP doesn't break any pages
- [ ] Test webhook with Stripe CLI
- [ ] Verify error logging in production
- [ ] Test order creation flow
- [ ] Verify email delivery

#### Staging Deployment
- Deploy to staging first
- Run full test suite
- Manual QA testing
- Load testing if possible
- Monitor for 24 hours before production

---

## Success Metrics

### Security Metrics
- **LetterOpener**: Zero production exposures (100% success)
- **Rate Limiting**: <1% legitimate requests blocked
- **CSP**: Zero violations in production logs
- **Webhook Security**: 100% signature verification success

### Functionality Metrics
- **Contact Form**: Emails delivered within 5 minutes (95% SLA)
- **Webhook Processing**: >99.9% success rate
- **Order Creation**: Zero failed orders due to bugs
- **Stock Updates**: 100% accuracy

### Code Quality Metrics
- **Test Coverage**: >50% overall (up from ~30%)
- **RuboCop**: Zero violations maintained
- **Code Complexity**: ABC metric improved by 20%
- **Technical Debt**: 3 critical issues resolved

### Performance Metrics
- **Response Time**: No degradation (p95 <500ms)
- **Error Rate**: <0.1% in production
- **Email Delivery**: 100% queue success rate

---

## Post-Sprint Review

### Retrospective Questions
1. What went well?
2. What could be improved?
3. What did we learn?
4. What should we do differently next sprint?

### Metrics to Track
- Story points completed vs planned
- Number of bugs found in production
- Time spent on unplanned work
- Test coverage increase
- Code quality improvements

### Next Sprint Planning
Based on analysis, recommended focus areas:
1. Admin 2FA implementation
2. Order tracking for customers
3. Inventory management alerts
4. Product search functionality
5. Performance optimization (N+1 queries)

---

## Appendix

### Environment Variables Required

```bash
# Production Environment Variables
ADMIN_EMAIL=admin@cariana.tech
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_WEBHOOK_KEY=whsec_xxx
RAILS_MASTER_KEY=xxx
DATABASE_URL=postgresql://xxx
REDIS_URL=redis://xxx
```

### Deployment Commands

```bash
# Deploy to staging
git push staging sprint-01

# Run migrations
heroku run rails db:migrate -r staging

# Deploy to production
git push production main

# Monitor logs
heroku logs --tail -r production
```

### Rollback Plan

If critical issues arise:
1. Revert deployment: `heroku releases:rollback -r production`
2. Disable rate limiting: Comment out middleware
3. Disable CSP: Set to report-only mode
4. Monitor Honeybadger for errors
5. Notify team immediately

---

**Sprint Owner**: TBD
**Scrum Master**: TBD
**Sprint Start Date**: TBD
**Sprint End Date**: TBD
**Review Date**: TBD
**Retrospective Date**: TBD
