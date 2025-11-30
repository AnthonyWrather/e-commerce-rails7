# frozen_string_literal: true

require 'test_helper'

class Users::ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @conversation = conversations(:conversation_one)
    sign_in @user
  end

  test 'should get index' do
    get conversations_url
    assert_response :success
    assert_select 'h1', 'My Messages'
  end

  test 'should show conversation' do
    get conversation_url(@conversation)
    assert_response :success
    assert_select '[data-controller="chat"]'
  end

  test 'should get new' do
    get new_conversation_url
    assert_response :success
    assert_select 'h1', 'Start New Chat'
  end

  test 'should create conversation' do
    assert_difference('Conversation.count', 1) do
      post conversations_url, params: {
        conversation: {
          subject: 'Test Subject',
          initial_message: 'Hello, I have a question.'
        }
      }
    end

    conversation = Conversation.last
    assert_equal 'Test Subject', conversation.subject
    assert_equal 'open', conversation.status
    assert_equal @user, conversation.user
    assert_redirected_to conversation_url(conversation)
  end

  test 'should create conversation with initial message' do
    assert_difference('Message.count', 1) do
      post conversations_url, params: {
        conversation: {
          subject: 'Test Subject',
          initial_message: 'Hello, I have a question.'
        }
      }
    end

    message = Message.last
    assert_equal 'Hello, I have a question.', message.content
    assert_equal @user, message.sender
  end

  test 'should create conversation without initial message' do
    assert_difference('Conversation.count', 1) do
      assert_no_difference('Message.count') do
        post conversations_url, params: {
          conversation: {
            subject: 'Test Subject Only',
            initial_message: ''
          }
        }
      end
    end
  end

  test 'should not show other users conversation' do
    other_user_conversation = conversations(:conversation_two)
    get conversation_url(other_user_conversation)
    assert_response :not_found
  end

  test 'should require authentication for index' do
    sign_out @user
    get '/conversations'
    assert_response :not_found
  end

  test 'should display online admin count' do
    get conversations_url
    assert_response :success
    assert_select '[data-presence-target="count"]'
  end

  test 'should display conversations list' do
    get conversations_url
    assert_response :success
    assert_match @conversation.subject, response.body
  end

  test 'should display empty state when no conversations' do
    @user.conversations.destroy_all
    get conversations_url
    assert_response :success
    assert_match 'No conversations yet', response.body
  end

  test 'should show conversation status badge' do
    get conversations_url
    assert_response :success
    assert_select 'span.rounded-full', minimum: 1
  end
end
