# frozen_string_literal: true

class PresenceChannel < ApplicationCable::Channel
  CHANNEL_NAME = 'presence_channel'

  def subscribed
    stream_from CHANNEL_NAME

    transmit_current_online_admins
  end

  def unsubscribed
    # Cleanup if needed
  end

  def self.broadcast_presence_update(presence)
    ActionCable.server.broadcast(
      CHANNEL_NAME,
      {
        admin_id: presence.admin_user_id,
        status: presence.status,
        admin_name: presence.admin_user.email
      }
    )
  end

  private

  def transmit_current_online_admins
    AdminPresence.online.includes(:admin_user).each do |presence|
      transmit({
                 admin_id: presence.admin_user.id,
                 status: presence.status,
                 admin_name: presence.admin_user.email
               })
    end
  end
end
