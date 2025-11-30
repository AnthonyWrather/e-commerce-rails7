# frozen_string_literal: true

require 'test_helper'

class HealthCheckTest < ActionDispatch::IntegrationTest
  # Tests for the /up health check endpoint used by:
  # - Render deployment health checks
  # - UptimeRobot external monitoring
  # - Load balancers

  test 'health check endpoint returns success when app is healthy' do
    get rails_health_check_url
    assert_response :success
  end

  test 'health check endpoint returns 200 status code' do
    get rails_health_check_url
    assert_equal 200, response.status
  end

  test 'health check route is accessible at /up' do
    get '/up'
    assert_response :success
  end

  test 'health check route is named rails_health_check' do
    assert_routing({ path: '/up', method: :get },
                   { controller: 'rails/health', action: 'show' })
  end

  test 'health check endpoint has correct content type' do
    get rails_health_check_url
    # Rails health check returns text/html by default
    assert_match %r{text/html}, response.content_type
  end
end
