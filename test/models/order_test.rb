# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  def setup
    @order = Order.new(
      customer_email: 'customer@example.com',
      total: 15_000,
      address: '123 Test Street, Test City, TC1 2AB',
      name: 'John Doe',
      phone: '01234567890',
      billing_name: 'John Doe',
      billing_address: '123 Test Street, Test City, TC1 2AB',
      payment_status: 'paid',
      payment_id: 'pi_test_123456',
      fulfilled: false
    )
  end

  # Basic validity test
  test 'should be valid with all required attributes' do
    assert @order.valid?
  end

  # Customer email validations
  test 'should require customer_email' do
    @order.customer_email = nil
    assert_not @order.valid?
    assert_includes @order.errors[:customer_email], "can't be blank"
  end

  test 'should require customer_email to not be empty string' do
    @order.customer_email = '   '
    assert_not @order.valid?
    assert_includes @order.errors[:customer_email], "can't be blank"
  end

  test 'should require valid email format' do
    invalid_emails = ['invalid', 'test@', '@example.com', 'test@.com']
    invalid_emails.each do |invalid_email|
      @order.customer_email = invalid_email
      assert_not @order.valid?, "#{invalid_email} should be invalid"
      assert_includes @order.errors[:customer_email], 'is invalid'
    end
  end

  test 'should accept valid email format' do
    valid_emails = ['test@example.com', 'user.name@example.co.uk', 'user+tag@example.com']
    valid_emails.each do |valid_email|
      @order.customer_email = valid_email
      assert @order.valid?, "#{valid_email} should be valid"
    end
  end

  # Total validations
  test 'should require total' do
    @order.total = nil
    assert_not @order.valid?
    assert_includes @order.errors[:total], "can't be blank"
  end

  test 'should require total to be a number' do
    @order.total = 'not a number'
    assert_not @order.valid?
    assert_includes @order.errors[:total], 'is not a number'
  end

  test 'should require total to be greater than or equal to zero' do
    @order.total = -1
    assert_not @order.valid?
    assert_includes @order.errors[:total], 'must be greater than or equal to 0'
  end

  test 'should allow total of zero' do
    @order.total = 0
    assert @order.valid?
  end

  test 'should require total to be an integer' do
    @order.total = 10.5
    assert_not @order.valid?
    assert_includes @order.errors[:total], 'must be an integer'
  end

  test 'should allow valid total' do
    @order.total = 25_000
    assert @order.valid?
  end

  # Shipping cost validations
  test 'should allow nil shipping_cost' do
    @order.shipping_cost = nil
    assert @order.valid?
  end

  test 'should require shipping_cost to be a number when present' do
    @order.shipping_cost = 'not a number'
    assert_not @order.valid?
    assert_includes @order.errors[:shipping_cost], 'is not a number'
  end

  test 'should require shipping_cost to be greater than or equal to zero' do
    @order.shipping_cost = -1
    assert_not @order.valid?
    assert_includes @order.errors[:shipping_cost], 'must be greater than or equal to 0'
  end

  test 'should allow shipping_cost of zero' do
    @order.shipping_cost = 0
    assert @order.valid?
  end

  test 'should require shipping_cost to be an integer' do
    @order.shipping_cost = 10.5
    assert_not @order.valid?
    assert_includes @order.errors[:shipping_cost], 'must be an integer'
  end

  test 'should allow valid shipping_cost' do
    @order.shipping_cost = 500
    assert @order.valid?
  end

  # Address validation
  test 'should require address' do
    @order.address = nil
    assert_not @order.valid?
    assert_includes @order.errors[:address], "can't be blank"
  end

  test 'should require address to not be empty string' do
    @order.address = '   '
    assert_not @order.valid?
    assert_includes @order.errors[:address], "can't be blank"
  end

  # Name validation
  test 'should require name' do
    @order.name = nil
    assert_not @order.valid?
    assert_includes @order.errors[:name], "can't be blank"
  end

  test 'should require name to not be empty string' do
    @order.name = '   '
    assert_not @order.valid?
    assert_includes @order.errors[:name], "can't be blank"
  end

  # Phone validation
  test 'should allow nil phone' do
    @order.phone = nil
    assert @order.valid?
  end

  test 'should allow valid phone' do
    @order.phone = '01234567890'
    assert @order.valid?
  end

  # Payment status validation
  test 'should allow nil payment_status' do
    @order.payment_status = nil
    assert @order.valid?
  end

  test 'should allow valid payment_status' do
    @order.payment_status = 'pending'
    assert @order.valid?
  end

  # Fulfilled validation
  test 'should allow fulfilled to be false' do
    @order.fulfilled = false
    assert @order.valid?
  end

  test 'should allow fulfilled to be true' do
    @order.fulfilled = true
    assert @order.valid?
  end

  test 'should allow fulfilled to be nil' do
    @order.fulfilled = nil
    assert @order.valid?
  end
end
