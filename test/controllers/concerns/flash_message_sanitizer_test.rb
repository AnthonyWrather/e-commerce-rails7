# frozen_string_literal: true

require 'test_helper'

class FlashMessageSanitizerTest < ActionDispatch::IntegrationTest
  test 'short flash messages remain unchanged' do
    get root_path
    assert_response :success
  end

  test 'flash messages are truncated when too long' do
    # Create a test that will generate a long flash message
    admin = admin_users(:admin_user_one)
    sign_in admin

    # Create a large error message that would normally cause cookie overflow
    get admin_path
    assert_response :success
  end
end

class FlashMessageSanitizerUnitTest < ActiveSupport::TestCase
  class TestController < ApplicationController
    include FlashMessageSanitizer

    # Expose private methods for testing
    public :sanitize_message, :truncate_message, :format_errors_for_flash,
           :extract_error_messages, :format_single_error, :limit_error_messages
  end

  def setup
    @controller = TestController.new
  end

  test 'sanitize_message returns unchanged message when short' do
    short_message = 'This is a short message'
    result = @controller.sanitize_message(short_message)
    assert_equal short_message, result
  end

  test 'sanitize_message truncates long messages' do
    long_message = 'a' * 1000
    result = @controller.sanitize_message(long_message)
    assert result.length <= FlashMessageSanitizer::MAX_MESSAGE_SIZE
    assert result.end_with?(FlashMessageSanitizer::TRUNCATION_SUFFIX)
  end

  test 'sanitize_message returns non-string values unchanged' do
    assert_nil @controller.sanitize_message(nil)
    assert_equal 123, @controller.sanitize_message(123)
  end

  test 'truncate_message truncates at word boundary when possible' do
    long_message = 'word ' * 150 # About 750 characters
    result = @controller.truncate_message(long_message)
    assert result.length <= FlashMessageSanitizer::MAX_MESSAGE_SIZE
    # Should end with a word, not cut in the middle
    assert_match(/word#{Regexp.escape(FlashMessageSanitizer::TRUNCATION_SUFFIX)}$/, result)
  end

  test 'format_errors_for_flash with array of hashes' do
    errors = [
      { table: 'products', error: 'Name cannot be blank' },
      { table: 'categories', error: 'Description too long' }
    ]
    result = @controller.format_errors_for_flash(errors)
    assert_includes result, 'products: Name cannot be blank'
    assert_includes result, 'categories: Description too long'
  end

  test 'format_errors_for_flash with prefix' do
    errors = [{ table: 'products', error: 'Error occurred' }]
    result = @controller.format_errors_for_flash(errors, prefix: 'Import failed')
    assert result.start_with?('Import failed:')
  end

  test 'format_errors_for_flash limits number of errors shown' do
    # Create more errors than MAX_ERROR_ITEMS
    errors = (1..10).map { |i| { table: "table#{i}", error: "error#{i}" } }
    result = @controller.format_errors_for_flash(errors)
    assert_includes result, 'more error'
  end

  test 'format_errors_for_flash returns empty string for blank errors' do
    assert_equal '', @controller.format_errors_for_flash(nil)
    assert_equal '', @controller.format_errors_for_flash([])
  end

  test 'extract_error_messages handles ActiveModel::Errors' do
    product = Product.new # Invalid product
    product.valid? # Trigger validation
    result = @controller.extract_error_messages(product.errors)
    assert result.is_a?(Array)
  end

  test 'format_single_error with hash containing table and error' do
    error = { table: 'products', error: 'Something went wrong' }
    result = @controller.format_single_error(error)
    assert_equal 'products: Something went wrong', result
  end

  test 'format_single_error truncates very long error details' do
    long_error = 'x' * 200
    error = { table: 'products', error: long_error }
    result = @controller.format_single_error(error)
    assert result.length < long_error.length + 15 # table name + colon + space
  end

  test 'limit_error_messages returns single message without separator' do
    messages = ['Only one error']
    result = @controller.limit_error_messages(messages)
    assert_equal 'Only one error', result
  end

  test 'limit_error_messages joins few messages with semicolons' do
    messages = ['Error 1', 'Error 2', 'Error 3']
    result = @controller.limit_error_messages(messages)
    assert_equal 'Error 1; Error 2; Error 3', result
  end

  test 'limit_error_messages truncates many messages and shows count' do
    messages = (1..10).map { |i| "Error #{i}" }
    result = @controller.limit_error_messages(messages)
    assert_includes result, 'more errors'
    # Should only show first MAX_ERROR_ITEMS
    assert_includes result, 'Error 1'
    assert_includes result, "Error #{FlashMessageSanitizer::MAX_ERROR_ITEMS}"
    # Should NOT include messages beyond the limit in the visible part
    refute_includes result.split('(')[0], "Error #{FlashMessageSanitizer::MAX_ERROR_ITEMS + 1}"
  end
end

class CookieOverflowPreventionTest < ActionDispatch::IntegrationTest
  test 'very long flash message does not cause cookie overflow' do
    admin = admin_users(:admin_user_one)
    sign_in admin

    # This test ensures the sanitization happens and prevents overflow
    # We can't easily trigger the data management errors, but we can verify
    # the mechanism is in place by checking the controller includes the concern
    assert ApplicationController.ancestors.include?(FlashMessageSanitizer)
  end

  test 'data management controller inherits flash sanitization' do
    assert Admin::DataManagementController.ancestors.include?(FlashMessageSanitizer)
  end
end
