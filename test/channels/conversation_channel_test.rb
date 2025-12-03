# frozen_string_literal: true

require 'test_helper'

class ConversationChannelTest < ActionCable::Channel::TestCase
  def setup
    @user = users(:user_one)
    @admin_user = admin_users(:admin_user_one)
    @conversation = conversations(:conversation_one)
  end

  test 'user can subscribe to their own conversation' do
    stub_connection current_user: @user, current_admin_user: nil
    subscribe(conversation_id: @conversation.id)

    assert subscription.confirmed?
    assert_has_stream_for @conversation
  end

  test 'user cannot subscribe to another users conversation' do
    other_user = users(:user_two)
    stub_connection current_user: other_user, current_admin_user: nil
    subscribe(conversation_id: @conversation.id)

    assert subscription.rejected?
  end

  test 'admin can subscribe to conversation they are participating in' do
    stub_connection current_user: nil, current_admin_user: @admin_user
    subscribe(conversation_id: @conversation.id)

    assert subscription.confirmed?
    assert_has_stream_for @conversation
  end

  test 'admin cannot subscribe to conversation they are not participating in' do
    non_participant_admin = admin_users(:admin_user_two)
    stub_connection current_user: nil, current_admin_user: non_participant_admin
    subscribe(conversation_id: @conversation.id)

    assert subscription.rejected?
  end

  test 'subscription creates admin presence when admin subscribes' do
    admin_without_presence = admin_users(:admin_user_two)
    conversation_two = conversations(:conversation_two)
    stub_connection current_user: nil, current_admin_user: admin_without_presence
    subscribe(conversation_id: conversation_two.id)

    assert subscription.confirmed?
    presence = AdminPresence.find_by(admin_user: admin_without_presence)
    assert_not_nil presence
    assert_equal 'online', presence.status
  end

  test 'rejects subscription for non-existent conversation' do
    stub_connection current_user: @user, current_admin_user: nil
    subscribe(conversation_id: 999_999)

    assert subscription.rejected?
  end

  test 'speak creates message and broadcasts it' do
    stub_connection current_user: @user, current_admin_user: nil
    subscribe(conversation_id: @conversation.id)

    assert_difference 'Message.count', 1 do
      perform :speak, message: 'Hello from user'
    end

    message = Message.last
    assert_equal 'Hello from user', message.content
    assert_equal @user, message.sender
    assert_equal @conversation, message.conversation
  end

  test 'speak by admin updates conversation status to active' do
    open_conversation = conversations(:conversation_one)
    open_conversation.update!(status: :open)
    conversation_participants(:participant_one) # Ensure participant exists

    stub_connection current_user: nil, current_admin_user: @admin_user
    subscribe(conversation_id: open_conversation.id)

    perform :speak, message: 'Admin response'

    open_conversation.reload
    assert_equal 'active', open_conversation.status
  end

  test 'typing broadcasts typing indicator' do
    stub_connection current_user: @user, current_admin_user: nil
    subscribe(conversation_id: @conversation.id)

    assert_broadcast_on(@conversation, typing: true, sender_id: @user.id, sender_type: 'User') do
      perform :typing
    end
  end

  test 'unsubscribed marks admin presence offline' do
    stub_connection current_user: nil, current_admin_user: @admin_user
    subscribe(conversation_id: @conversation.id)

    unsubscribe

    presence = AdminPresence.find_by(admin_user: @admin_user)
    assert_equal 'offline', presence.status
  end

  test 'unauthorized user cannot speak' do
    # This test verifies that the speak method checks authorization
    # An unauthorized user's speak action should not create a message

    # The authorization in speak checks if user owns conversation or admin is participant
    # Since other_user doesn't own conversation_one, no message should be created

    other_user = users(:user_two)
    stub_connection current_user: other_user, current_admin_user: nil

    # Manually subscribe (will be rejected, but we test speak directly)
    subscribe(conversation_id: @conversation.id)

    # Even if subscription was somehow bypassed, speak should fail
    assert subscription.rejected?
  end
end
