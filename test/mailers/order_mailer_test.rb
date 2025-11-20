# frozen_string_literal: true

require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  test 'new_order_email' do
    order = orders(:order_one)
    mail = OrderMailer.new_order_email(order)
    assert_equal 'Your order has been received', mail.subject
    assert_equal [order.customer_email], mail.to
    assert_equal ['scfs@cariana.tech'], mail.from
    assert_match order.name, mail.body.encoded
  end
end
