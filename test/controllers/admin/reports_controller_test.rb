# frozen_string_literal: true

require 'test_helper'

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in admin_users(:admin_user_one)
  end

  test 'should get index' do
    get admin_reports_url
    assert_response :success
  end
end
