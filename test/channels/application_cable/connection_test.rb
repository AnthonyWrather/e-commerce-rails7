# frozen_string_literal: true

require 'test_helper'

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    def setup
      @user = users(:user_one)
      @admin_user = admin_users(:admin_user_one)
    end

    test 'connects with user session' do
      connect_with_user_session(@user)

      assert_equal @user.id, connection.current_user.id
      assert_nil connection.current_admin_user
    end

    test 'connects with admin_user session' do
      connect_with_admin_session(@admin_user)

      assert_equal @admin_user.id, connection.current_admin_user.id
      assert_nil connection.current_user
    end

    test 'connects with both user and admin_user sessions' do
      connect_with_both_sessions(@user, @admin_user)

      assert_equal @user.id, connection.current_user.id
      assert_equal @admin_user.id, connection.current_admin_user.id
    end

    test 'rejects unauthorized connection when no valid session' do
      assert_reject_connection do
        connect
      end
    end

    test 'rejects connection when user does not exist' do
      session_data = { 'warden.user.user.key' => [[999_999]] }
      cookies.encrypted[session_key] = session_data

      assert_reject_connection do
        connect
      end
    end

    test 'rejects connection when admin_user does not exist' do
      session_data = { 'warden.user.admin_user.key' => [[999_999]] }
      cookies.encrypted[session_key] = session_data

      assert_reject_connection do
        connect
      end
    end

    private

    def connect_with_user_session(user)
      session_data = { 'warden.user.user.key' => [[user.id]] }
      cookies.encrypted[session_key] = session_data
      connect
    end

    def connect_with_admin_session(admin_user)
      session_data = { 'warden.user.admin_user.key' => [[admin_user.id]] }
      cookies.encrypted[session_key] = session_data
      connect
    end

    def connect_with_both_sessions(user, admin_user)
      session_data = {
        'warden.user.user.key' => [[user.id]],
        'warden.user.admin_user.key' => [[admin_user.id]]
      }
      cookies.encrypted[session_key] = session_data
      connect
    end

    def session_key
      Rails.application.config.session_options[:key]
    end
  end
end
