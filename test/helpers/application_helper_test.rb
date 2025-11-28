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
end
