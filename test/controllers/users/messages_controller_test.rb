# frozen_string_literal: true

require 'test_helper'

class Users::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @conversation = conversations(:conversation_one)
    sign_in @user
  end

  test 'should create message' do
    assert_difference('Message.count', 1) do
      post conversation_messages_url(@conversation), params: {
        message: {
          content: 'Test message content'
        }
      }, as: :json
    end

    assert_response :success
    message = Message.last
    assert_equal 'Test message content', message.content
    assert_equal @user, message.sender
    assert_equal @conversation, message.conversation
  end

  test 'should not create message with empty content' do
    assert_no_difference('Message.count') do
      post conversation_messages_url(@conversation), params: {
        message: {
          content: ''
        }
      }, as: :json
    end

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_includes json_response['errors'], "Content can't be blank"
  end

  test 'should not allow creating message in other users conversation' do
    other_user_conversation = conversations(:conversation_two)
    post conversation_messages_url(other_user_conversation), params: {
      message: {
        content: 'Trying to send to another conversation'
      }
    }

    assert_redirected_to conversations_path
    follow_redirect!
    assert_match 'not authorized', response.body
  end

  test 'should require authentication' do
    sign_out @user
    post "/conversations/#{@conversation.id}/messages", params: {
      message: { content: 'Test' }
    }
    # Since routes are wrapped in authenticated :user block,
    # unauthenticated requests get 404
    assert_response :not_found
  end

  test 'should update conversation last_message_at on message create' do
    original_time = @conversation.last_message_at
    travel 1.hour do
      post conversation_messages_url(@conversation), params: {
        message: { content: 'New message' }
      }, as: :json
    end

    @conversation.reload
    assert @conversation.last_message_at > original_time if original_time
  end
end
