# frozen_string_literal: true

require 'test_helper'

class ContactControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test 'should get index' do
    get contact_url
    assert_response :success
  end

  test 'should send email with valid form submission' do
    assert_enqueued_emails 1 do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          message: 'Hello, I have a question.'
        }
      }
    end

    assert_redirected_to contact_url
    follow_redirect!
    assert_match 'Your message has been sent successfully.', flash[:success]
  end

  test 'should reject empty first name' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: '',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          message: 'Hello'
        }
      }
    end

    assert_redirected_to contact_url
    follow_redirect!
    assert_match 'First name is required', flash[:error]
  end

  test 'should reject empty last name' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: '',
          email: 'john.doe@example.com',
          message: 'Hello'
        }
      }
    end

    assert_redirected_to contact_url
    follow_redirect!
    assert_match 'Last name is required', flash[:error]
  end

  test 'should reject empty email' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: '',
          message: 'Hello'
        }
      }
    end

    assert_redirected_to contact_url
    follow_redirect!
    assert_match 'Email is required', flash[:error]
  end

  test 'should reject empty message' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com',
          message: ''
        }
      }
    end

    assert_redirected_to contact_url
    follow_redirect!
    assert_match 'Message is required', flash[:error]
  end

  test 'should reject invalid email format' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: 'John',
          last_name: 'Doe',
          email: 'invalid-email',
          message: 'Hello'
        }
      }
    end

    assert_redirected_to contact_url
    follow_redirect!
    assert_match 'Email format is invalid', flash[:error]
  end

  test 'should show multiple errors when multiple fields are empty' do
    assert_no_enqueued_emails do
      post contact_url, params: {
        contact_form: {
          first_name: '',
          last_name: '',
          email: '',
          message: ''
        }
      }
    end

    assert_redirected_to contact_url
    follow_redirect!
    assert_match 'First name is required', flash[:error]
    assert_match 'Last name is required', flash[:error]
    assert_match 'Email is required', flash[:error]
    assert_match 'Message is required', flash[:error]
  end
end
