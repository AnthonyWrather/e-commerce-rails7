# frozen_string_literal: true

# Controller for testing Honeybadger error reporting
# Only available in test and development environments
class Admin::TestErrorsController < AdminController
  # Test errors controller available in all environments

  # GET /admin/test_errors
  def index
    @error_types = %w[
      standard_error
      argument_error
      runtime_error
      custom_error
      notify_only
    ]
  end

  # POST /admin/test_errors/trigger
  def trigger
    error_type = params[:error_type]

    case error_type
    when 'standard_error'
      raise StandardError, 'Test StandardError from Honeybadger test'
    when 'argument_error'
      raise ArgumentError, 'Test ArgumentError from Honeybadger test'
    when 'runtime_error'
      raise 'Test RuntimeError from Honeybadger test'
    when 'custom_error'
      raise CustomTestError, 'Test CustomError from Honeybadger test'
    when 'notify_only'
      Honeybadger.notify(
        StandardError.new('Test notification without raising'),
        context: {
          test_mode: true,
          triggered_at: Time.current,
          user: current_admin_user&.email
        }
      )
      redirect_to admin_test_errors_path, notice: 'Honeybadger notification sent (no exception raised)'
    else
      redirect_to admin_test_errors_path, alert: 'Invalid error type'
    end
  end

  # Custom error class for testing
  class CustomTestError < StandardError; end
end
