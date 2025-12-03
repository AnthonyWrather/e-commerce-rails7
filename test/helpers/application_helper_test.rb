# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'formatted_price returns £0.00 for nil' do
    assert_equal '£0.00', formatted_price(nil)
  end

  test 'formatted_price returns £0.00 for zero' do
    assert_equal '£0.00', formatted_price(0)
  end

  test 'formatted_price converts pence to pounds' do
    assert_equal '£10.00', formatted_price(1000)
  end

  test 'formatted_price handles decimal pence' do
    assert_equal '£10.01', formatted_price(1001)
  end

  test 'formatted_price formats large amounts correctly' do
    assert_equal '£1,234.56', formatted_price(123_456)
  end

  test 'formatted_price handles single digit pence' do
    assert_equal '£10.05', formatted_price(1005)
  end

  test 'formatted_price handles amounts under one pound' do
    assert_equal '£0.99', formatted_price(99)
  end

  test 'formatted_price handles single pence' do
    assert_equal '£0.01', formatted_price(1)
  end

  test 'formatted_price handles very large amounts' do
    assert_equal '£10,000.00', formatted_price(1_000_000)
  end

  test 'formatted_price with VAT calculation' do
    # Common pattern: price includes VAT, calculate ex-VAT
    price_inc_vat = 1200 # £12.00
    price_ex_vat = price_inc_vat / 1.2

    assert_equal '£10.00', formatted_price(price_ex_vat.to_i)
  end

  # Honeybadger JavaScript helper tests
  test 'honeybadger_js_enabled? returns false when API key is not present' do
    original_api_key = Honeybadger.config[:api_key]
    Honeybadger.config[:api_key] = nil
    assert_not honeybadger_js_enabled?
    Honeybadger.config[:api_key] = original_api_key
  end

  test 'honeybadger_js_enabled? returns true in test environment with API key' do
    original_api_key = Honeybadger.config[:api_key]
    Honeybadger.config[:api_key] = 'test_api_key'
    assert honeybadger_js_enabled?
    Honeybadger.config[:api_key] = original_api_key
  end

  test 'honeybadger_user_context returns guest context when no user is logged in' do
    context = honeybadger_user_context
    assert_nil context[:id]
    assert_nil context[:email]
    assert_equal 'guest', context[:type]
  end
end

# Test with mocked current_user
class ApplicationHelperWithUserTest < ActionView::TestCase
  include ApplicationHelper

  attr_accessor :current_user

  test 'honeybadger_user_context returns user context when user is logged in' do
    user = users(:user_one)
    self.current_user = user

    context = honeybadger_user_context
    assert_equal user.id, context[:id]
    assert_equal user.email, context[:email]
    assert_equal 'user', context[:type]
  end
end

# Test with mocked current_admin_user
class ApplicationHelperWithAdminTest < ActionView::TestCase
  include ApplicationHelper

  attr_accessor :current_admin_user

  test 'honeybadger_user_context returns admin context when admin is logged in' do
    admin = admin_users(:admin_user_one)
    self.current_admin_user = admin

    context = honeybadger_user_context
    assert_equal admin.id, context[:id]
    assert_equal admin.email, context[:email]
    assert_equal 'admin', context[:type]
  end
end
