# frozen_string_literal: true

require 'application_system_test_case'

class CustomerChatTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    @conversation = conversations(:conversation_one)
  end

  test 'user can view messages list' do
    sign_in @user
    visit conversations_path

    assert_selector 'h1', text: 'My Messages'
  end

  test 'user can see admin availability indicator on messages page' do
    sign_in @user
    visit conversations_path

    assert_selector '[data-controller="presence"]'
    assert_text 'administrator'
    assert_text 'online'
  end

  test 'user can view their conversations' do
    sign_in @user
    visit conversations_path

    assert_text @conversation.subject
  end

  test 'user can start a new chat' do
    sign_in @user
    visit conversations_path

    click_link 'Start New Chat'
    assert_selector 'h1', text: 'Start New Chat'

    fill_in 'Subject', with: 'Test Chat Subject'
    fill_in 'Your message', with: 'Hello, I need help with my order'
    click_button 'Start Chat'

    assert_text 'Chat started'
    assert_selector '[data-controller="chat"]'
  end

  test 'user can view a conversation' do
    sign_in @user
    visit conversations_path

    click_link @conversation.subject
    assert_selector '[data-controller="chat"]'
    assert_text @conversation.subject
  end

  test 'user sees empty state when no conversations' do
    @user.conversations.destroy_all
    sign_in @user
    visit conversations_path

    assert_text 'No conversations yet'
    assert_link 'Start New Chat'
  end

  test 'messages sidebar shows link to messages' do
    sign_in @user
    visit account_path

    assert_link 'Messages'
    click_link 'Messages'
    assert_selector 'h1', text: 'My Messages'
  end

  test 'user can see conversation status' do
    sign_in @user
    visit conversations_path

    assert_selector 'span.rounded-full', minimum: 1
  end

  test 'chat view shows message input' do
    sign_in @user
    visit conversation_path(@conversation)

    assert_selector 'input[placeholder*="Type your message"]'
    assert_selector 'button', text: 'Send'
  end

  test 'user can see admin online status in chat view' do
    sign_in @user
    visit conversation_path(@conversation)

    assert_selector '[data-controller="presence"]'
    assert_text 'admin'
    assert_text 'online'
  end
end
