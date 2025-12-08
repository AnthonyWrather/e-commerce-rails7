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

  test 'shows error reporting status' do
    visit admin_test_errors_url

    # In test environment, error reporting is disabled unless HONEYBADGER_ENABLED_IN_TEST=true
    if ENV['HONEYBADGER_ENABLED_IN_TEST'] == 'true'
      assert_text 'Error Reporting Enabled'
    else
      assert_text 'Error Reporting Disabled'
    end
  end

  test 'displays configuration information' do
    visit admin_test_errors_url

    assert_text 'Configuration Information'
    assert_text "Environment: #{Rails.env}"
    assert_text 'Honeybadger API Key Set:'
    if ENV['HONEYBADGER_ENABLED_IN_TEST'] == 'true'
      assert_text 'Test Error Reporting: Enabled'
      assert_text 'Insights Enabled: Yes'
    else
      assert_text 'Test Error Reporting: Disabled'
      assert_text 'Insights Enabled: No'
    end
  end

  test 'notify only error shows in list' do
    visit admin_test_errors_url

    # Just verify that the "Notify Only" option is visible in the list
    assert_text 'Notify Only'
    assert_text 'Sends a notification without raising an exception'
  end
end
