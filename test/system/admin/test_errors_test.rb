# frozen_string_literal: true

require 'application_system_test_case'

class Admin::TestErrorsTest < ApplicationSystemTestCase
  setup do
    @admin_user = admin_users(:admin_user_one)
    sign_in_admin(@admin_user)
  end

  test 'visiting the test errors page' do
    visit admin_test_errors_url

    assert_selector 'h1', text: 'Honeybadger Error Testing'
    assert_text 'Available Error Types'
  end

  test 'displays all error types' do
    visit admin_test_errors_url

    assert_text 'Standard Error'
    assert_text 'Argument Error'
    assert_text 'Runtime Error'
    assert_text 'Custom Error'
    assert_text 'Notify Only'
  end

  test 'shows test mode status' do
    visit admin_test_errors_url

    if ENV['HONEYBADGER_TEST_MODE'] == 'true'
      assert_text 'Test Mode Enabled'
    else
      assert_text 'Test Mode Disabled'
    end
  end

  test 'displays configuration information' do
    visit admin_test_errors_url

    assert_text 'Configuration Information'
    assert_text "Environment: #{Rails.env}"
    assert_text 'Honeybadger API Key Set:'
    assert_text 'Test Mode:'
    assert_text 'Report Data:'
  end

  test 'notify only error shows in list' do
    visit admin_test_errors_url

    # Just verify that the "Notify Only" option is visible in the list
    assert_text 'Notify Only'
    assert_text 'Sends a notification without raising an exception'
  end
end
