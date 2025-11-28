# frozen_string_literal: true

require 'test_helper'

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @order = orders(:order_one)
  end

  test 'new_order_email sends with correct headers' do
    mail = OrderMailer.new_order_email(@order)
    assert_equal 'Your order has been received', mail.subject
    assert_equal [@order.customer_email], mail.to
    assert_equal ['scfs@cariana.tech'], mail.from
  end

  test 'new_order_email includes customer name in body' do
    mail = OrderMailer.new_order_email(@order)
    assert_match @order.name, mail.body.encoded
  end

  test 'new_order_email includes order total in body' do
    mail = OrderMailer.new_order_email(@order)
    # Order total is 15000 pence = £150.00
    assert_match '150', mail.body.encoded
  end

  test 'new_order_email includes shipping address in body' do
    mail = OrderMailer.new_order_email(@order)
    assert_match @order.address, mail.body.encoded
  end

  test 'new_order_email includes greeting message' do
    mail = OrderMailer.new_order_email(@order)
    # The actual message is "Order Number ... has been received"
    assert_match 'has been received', mail.body.encoded
  end

  test 'new_order_email is multipart with html and text parts' do
    mail = OrderMailer.new_order_email(@order)
    assert mail.multipart?
    assert_equal 2, mail.parts.length
    assert_equal 'text/plain', mail.parts[0].content_type.split(';').first
    assert_equal 'text/html', mail.parts[1].content_type.split(';').first
  end

  test 'new_order_email html part contains customer name' do
    mail = OrderMailer.new_order_email(@order)
    html_part = mail.parts.find { |p| p.content_type.match(/html/) }
    assert_match @order.name, html_part.body.encoded
  end

  test 'new_order_email text part contains customer name' do
    mail = OrderMailer.new_order_email(@order)
    text_part = mail.parts.find { |p| p.content_type.match(/plain/) }
    assert_match @order.name, text_part.body.encoded
  end
end
