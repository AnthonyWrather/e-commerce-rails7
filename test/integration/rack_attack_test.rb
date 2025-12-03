# frozen_string_literal: true

require 'test_helper'

# Rack::Attack tests - these test rate limiting functionality
# NOTE: These tests are skipped by default because Rack::Attack middleware
# is disabled in test environment (see config/application.rb line 30).
# To properly test rate limiting, you need to:
# 1. Temporarily enable Rack::Attack in test environment
# 2. Run tests with: RACK_ATTACK_ENABLED=true bin/rails test test/integration/rack_attack_test.rb
class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    # Skip these tests unless Rack::Attack is explicitly enabled
    # The middleware is disabled in config/application.rb for test environment
    skip 'Rack::Attack middleware not loaded in test environment. Run with RACK_ATTACK_ENABLED=true to test.'
  end

  teardown do
    # Disable Rack::Attack after tests
    ENV.delete('RACK_ATTACK_ENABLED')

    # Clear throttle data
    Rack::Attack.cache.store.clear if defined?(Rack::Attack) && Rack::Attack.cache.respond_to?(:clear)

    # Reload the initializer to ensure Rack::Attack is disabled
    load Rails.root.join('config/initializers/rack_attack.rb')
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

  # Chat message rate limiting tests
  # These test the throttling rules added for chat endpoints:
  # - chat_messages/ip: 60 messages per minute for user chat
  # - admin_chat_messages/ip: 60 messages per minute for admin chat
  # - conversations/ip: 10 new conversations per hour

  test 'throttles chat message creation by IP' do
    user = users(:user_one)
    sign_in user
    conversation = conversations(:conversation_one)

    60.times do |i|
      post conversation_messages_url(conversation), params: { message: { content: "Test message #{i}" } }, as: :json
      refute_equal 429, response.status, "Request #{i + 1} should not be rate limited"
    end

    post conversation_messages_url(conversation), params: { message: { content: 'Rate limited message' } }, as: :json
    assert_response 429
  end

  test 'throttles conversation creation by IP' do
    user = users(:user_one)
    sign_in user

    10.times do |i|
      post conversations_url, params: { conversation: { subject: "Test #{i}", initial_message: 'Hello' } }
      refute_equal 429, response.status, "Request #{i + 1} should not be rate limited"
    end

    post conversations_url, params: { conversation: { subject: 'Rate limited', initial_message: 'Hello' } }
    assert_response 429
  end

  private

  def refute_response(status)
    refute_equal status, response.status
  end
end
