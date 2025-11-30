# frozen_string_literal: true

require 'test_helper'

class Admin::MessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:admin_user_one)
    @conversation = conversations(:conversation_one)
    sign_in @admin_user
  end

  test 'should create message when admin is assigned' do
    ConversationParticipant.find_or_create_by(
      conversation: @conversation,
      admin_user: @admin_user
    )

    assert_difference 'Message.count', 1 do
      post admin_conversation_messages_url(@conversation), params: {
        message: { content: 'Hello from admin!' }
      }, as: :json
    end

    assert_response :success

    message = Message.last
    assert_equal 'Hello from admin!', message.content
    assert_equal @admin_user, message.sender
    assert_equal 'AdminUser', message.sender_type
  end

  test 'should redirect when admin is not assigned' do
    @conversation.conversation_participants.where(admin_user: @admin_user).destroy_all

    post admin_conversation_messages_url(@conversation), params: {
      message: { content: 'Unauthorized message' }
    }

    assert_redirected_to admin_conversations_path
    assert_equal 'You must be assigned to this conversation to send messages.', flash[:alert]
  end

  test 'should return error for invalid message' do
    ConversationParticipant.find_or_create_by(
      conversation: @conversation,
      admin_user: @admin_user
    )

    post admin_conversation_messages_url(@conversation), params: {
      message: { content: '' }
    }, as: :json

    assert_response :unprocessable_content
  end

  test 'should update open conversation to active when admin sends message' do
    @conversation.update!(status: :open)
    ConversationParticipant.find_or_create_by(
      conversation: @conversation,
      admin_user: @admin_user
    )

    post admin_conversation_messages_url(@conversation), params: {
      message: { content: 'Activating conversation!' }
    }, as: :json

    assert_response :success
    assert_equal 'active', @conversation.reload.status
  end

  test 'should require authentication' do
    sign_out @admin_user

    post admin_conversation_messages_url(@conversation), params: {
      message: { content: 'Test' }
    }

    assert_redirected_to new_admin_user_session_path
  end
end
