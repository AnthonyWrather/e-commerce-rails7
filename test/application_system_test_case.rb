# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Using rack_test driver for now due to Chrome version compatibility issues
  # Chrome 142 is a dev/canary version not supported by available ChromeDrivers
  # This driver doesn't support JavaScript but allows basic system tests to run
  driven_by :rack_test

  include Devise::Test::IntegrationHelpers
  include TwoFactorTestHelpers

  def sign_in_admin(admin = nil)
    admin ||= admin_users(:admin_user_one)
    sign_in admin
  end
end
