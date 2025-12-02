# frozen_string_literal: true

require 'test_helper'

class Admin::TestErrorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = admin_users(:admin_user_one)
    sign_in @admin_user
  end

  test 'should get index' do
    get admin_test_errors_url
    assert_response :success
    assert_select 'h1', text: /Honeybadger Error Testing/
  end

  test 'should display error types' do
    get admin_test_errors_url
    assert_response :success
    assert_select 'h3', text: /Standard Error/
    assert_select 'h3', text: /Argument Error/
    assert_select 'h3', text: /Runtime Error/
    assert_select 'h3', text: /Custom Error/
    assert_select 'h3', text: /Notify Only/
  end

  test 'should trigger standard error' do
    assert_raises(StandardError) do
      post trigger_admin_test_errors_url, params: { error_type: 'standard_error' }
    end
  end

  test 'should trigger argument error' do
    assert_raises(ArgumentError) do
      post trigger_admin_test_errors_url, params: { error_type: 'argument_error' }
    end
  end

  test 'should trigger runtime error' do
    assert_raises(RuntimeError) do
      post trigger_admin_test_errors_url, params: { error_type: 'runtime_error' }
    end
  end

  test 'should trigger custom error' do
    assert_raises(Admin::TestErrorsController::CustomTestError) do
      post trigger_admin_test_errors_url, params: { error_type: 'custom_error' }
    end
  end

  test 'should send notify only without raising' do
    post trigger_admin_test_errors_url, params: { error_type: 'notify_only' }
    assert_redirected_to admin_test_errors_url
    assert_match(/notification sent/, flash[:notice])
  end

  test 'should reject invalid error type' do
    post trigger_admin_test_errors_url, params: { error_type: 'invalid_type' }
    assert_redirected_to admin_test_errors_url
    assert_match(/Invalid error type/, flash[:alert])
  end

  test 'should require admin authentication' do
    sign_out @admin_user
    get admin_test_errors_url
    assert_redirected_to new_admin_user_session_url
  end

  test 'should show test mode status' do
    get admin_test_errors_url
    assert_response :success

    if ENV['HONEYBADGER_TEST_MODE'] == 'true'
      assert_select 'span', text: /Test Mode Enabled/
    else
      assert_select 'span', text: /Test Mode Disabled/
    end
  end

  test 'should display configuration information' do
    get admin_test_errors_url
    assert_response :success
    assert_select 'h3', text: /Configuration Information/
    assert_match(/Environment:/, response.body)
    assert_match(/Honeybadger API Key Set:/, response.body)
    assert_match(/Test Mode:/, response.body)
    assert_match(/Report Data:/, response.body)
  end
end
