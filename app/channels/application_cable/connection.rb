# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_admin_user

    def connect
      self.current_user = find_verified_user
      self.current_admin_user = find_verified_admin_user

      reject_unauthorized_connection if current_user.nil? && current_admin_user.nil?
    end

    private

    def find_verified_user
      user_id = extract_user_id_from_session
      User.find_by(id: user_id) if user_id
    end

    def find_verified_admin_user
      admin_user_id = extract_admin_user_id_from_session
      AdminUser.find_by(id: admin_user_id) if admin_user_id
    end

    def extract_user_id_from_session
      session_data = cookies.encrypted[session_key]
      return nil unless session_data

      session_data.dig('warden.user.user.key', 0, 0)
    end

    def extract_admin_user_id_from_session
      session_data = cookies.encrypted[session_key]
      return nil unless session_data

      session_data.dig('warden.user.admin_user.key', 0, 0)
    end

    def session_key
      Rails.application.config.session_options[:key]
    end
  end
end
