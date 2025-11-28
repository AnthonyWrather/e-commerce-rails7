# frozen_string_literal: true

require 'test_helper'

class ContactMailerTest < ActionMailer::TestCase
  test 'contact_email sends email with correct attributes' do
    mail = ContactMailer.contact_email(
      first_name: 'John',
      last_name: 'Doe',
      email: 'john.doe@example.com',
      message: 'Hello, I have a question about your products.'
    )

    assert_equal 'Contact Form Submission from John Doe', mail.subject
    assert_equal ['admin@cariana.tech'], mail.to
    assert_equal ['scfs@cariana.tech'], mail.from
    assert_equal ['john.doe@example.com'], mail.reply_to
    assert_match 'John', mail.body.encoded
    assert_match 'Doe', mail.body.encoded
    assert_match 'john.doe@example.com', mail.body.encoded
    assert_match 'Hello, I have a question about your products.', mail.body.encoded
  end

  test 'contact_email uses ADMIN_EMAIL environment variable when set' do
    original_admin_email = ENV.fetch('ADMIN_EMAIL', nil)
    ENV['ADMIN_EMAIL'] = 'custom-admin@example.com'

    mail = ContactMailer.contact_email(
      first_name: 'Jane',
      last_name: 'Smith',
      email: 'jane.smith@example.com',
      message: 'Test message'
    )

    assert_equal ['custom-admin@example.com'], mail.to

    ENV['ADMIN_EMAIL'] = original_admin_email
  end
end
