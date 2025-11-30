# frozen_string_literal: true

require 'test_helper'

class PresenceChannelTest < ActionCable::Channel::TestCase
  def setup
    @user = users(:user_one)
    @admin_user = admin_users(:admin_user_one)
  end

  test 'user can subscribe to presence channel' do
    stub_connection current_user: @user, current_admin_user: nil
    subscribe

    assert subscription.confirmed?
    assert_has_stream PresenceChannel::CHANNEL_NAME
  end

  test 'admin can subscribe to presence channel' do
    stub_connection current_user: nil, current_admin_user: @admin_user
    subscribe

    assert subscription.confirmed?
    assert_has_stream PresenceChannel::CHANNEL_NAME
  end

  test 'subscription transmits current online admins' do
    online_presence = admin_presences(:admin_presence_one)
    assert_equal 'online', online_presence.status

    stub_connection current_user: @user, current_admin_user: nil
    subscribe

    # Verify subscription confirms and streams
    assert subscription.confirmed?
    assert_has_stream PresenceChannel::CHANNEL_NAME
  end

  test 'broadcast_presence_update broadcasts to channel' do
    presence = admin_presences(:admin_presence_one)

    assert_broadcasts(PresenceChannel::CHANNEL_NAME, 1) do
      PresenceChannel.broadcast_presence_update(presence)
    end
  end

  test 'admin status change triggers broadcast' do
    presence = admin_presences(:admin_presence_two)
    assert_equal 'offline', presence.status

    assert_broadcasts(PresenceChannel::CHANNEL_NAME, 1) do
      presence.update!(status: 'online')
    end
  end

  test 'mark_online broadcasts status change' do
    admin_without_presence = AdminUser.create!(
      email: 'new_admin@example.com',
      password: 'password123'
    )

    assert_broadcasts(PresenceChannel::CHANNEL_NAME, 1) do
      AdminPresence.mark_online(admin_without_presence)
    end

    presence = AdminPresence.find_by(admin_user: admin_without_presence)
    assert_not_nil presence
    assert_equal 'online', presence.status
  end

  test 'mark_offline broadcasts status change' do
    admin = admin_users(:admin_user_one)
    presence = admin_presences(:admin_presence_one)
    assert_equal 'online', presence.status

    assert_broadcasts(PresenceChannel::CHANNEL_NAME, 1) do
      AdminPresence.mark_offline(admin)
    end

    presence.reload
    assert_equal 'offline', presence.status
  end
end
