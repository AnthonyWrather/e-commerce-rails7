# frozen_string_literal: true

require 'test_helper'

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    # Configure and reset Rack::Attack cache for each test
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.reset!
  end

  test 'throttles requests exceeding 300 per 5 minutes per IP' do
    300.times do |i|
      get root_url
      assert_response :success, "Request #{i + 1} should succeed"
    end

    get root_url
    assert_response 429
  end

  test 'does not throttle asset requests' do
    301.times do
      get '/assets/application.css'
    end
    # Should not return 429 for asset requests (they are excluded from throttling)
    refute_response 429
  end

  test 'throttles admin login attempts by IP' do
    5.times do |i|
      post admin_user_session_url, params: { admin_user: { email: 'test@test.com', password: 'wrong' } }
      # Devise returns 422 for invalid credentials, but should not be 429 yet
      refute_equal 429, response.status, "Request #{i + 1} should not be rate limited"
    end

    post admin_user_session_url, params: { admin_user: { email: 'test@test.com', password: 'wrong' } }
    assert_response 429
  end

  test 'throttles admin login attempts by email' do
    5.times do |i|
      post admin_user_session_url, params: { admin_user: { email: 'attacker@test.com', password: 'wrong' } }
      refute_equal 429, response.status, "Request #{i + 1} should not be rate limited"
    end

    post admin_user_session_url, params: { admin_user: { email: 'attacker@test.com', password: 'wrong' } }
    assert_response 429
  end

  test 'throttles contact form submissions by IP' do
    5.times do |i|
      post contact_url, params: { contact_form: { first_name: 'Test', last_name: 'User', email: 'test@test.com', message: 'Hello' } }
      refute_equal 429, response.status, "Request #{i + 1} should not be rate limited"
    end

    post contact_url, params: { contact_form: { first_name: 'Test', last_name: 'User', email: 'test@test.com', message: 'Hello' } }
    assert_response 429
  end

  test 'returns 429 status with appropriate message when throttled' do
    6.times do
      post admin_user_session_url, params: { admin_user: { email: 'test@test.com', password: 'wrong' } }
    end

    assert_response 429
    assert_equal 'Too Many Requests. Please try again later.', response.body
  end

  private

  def refute_response(status)
    refute_equal status, response.status
  end
end
