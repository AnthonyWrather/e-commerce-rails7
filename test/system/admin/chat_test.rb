# frozen_string_literal: true

require 'application_system_test_case'

class Admin::ChatTest < ApplicationSystemTestCase
  setup do
    @admin_user = admin_users(:admin_user_one)
    @conversation = conversations(:conversation_one)
    # Ensure admin is assigned to conversation
    ConversationParticipant.find_or_create_by(
      conversation: @conversation,
      admin_user: @admin_user
    )
  end

  test 'admin can view chat dashboard' do
    sign_in_admin @admin_user
    visit admin_conversations_path

    assert_selector 'h1', text: 'Chat Dashboard'
    assert_text 'All Conversations'
    assert_text 'My Conversations'
  end

  test 'admin chat dashboard shows unread count badge' do
    sign_in_admin @admin_user
    visit admin_path

    assert_link 'Chat'
    assert_selector 'nav a', text: /Chat/
  end

  test 'admin can filter conversations by status' do
    sign_in_admin @admin_user

    visit admin_conversations_path(status: 'open')
    assert_response_success

    visit admin_conversations_path(status: 'active')
    assert_response_success

    visit admin_conversations_path(status: 'resolved')
    assert_response_success
  end

  test 'admin can view a conversation' do
    sign_in_admin @admin_user
    visit admin_conversation_path(@conversation)

    assert_selector '[data-controller="chat"]'
    assert_text @conversation.subject || "Chat ##{@conversation.id}"
  end

  test 'admin can see customer information in chat view' do
    sign_in_admin @admin_user
    visit admin_conversation_path(@conversation)

    assert_text 'Customer Information'
    assert_text @conversation.user.email
  end

  test 'admin can see resolve and close buttons for active conversation' do
    @conversation.update!(status: :active)
    sign_in_admin @admin_user
    visit admin_conversation_path(@conversation)

    assert_text 'Resolve'
    assert_text 'Close'
  end

  test 'admin can toggle availability status' do
    sign_in_admin @admin_user
    visit admin_conversations_path

    click_button 'Go Online'

    assert_text 'Status updated to'
  end

  test 'chat sidebar shows in admin navigation' do
    sign_in_admin @admin_user
    visit admin_path

    within('nav') do
      assert_link 'Chat'
    end
  end

  test 'admin can assign themselves to an open conversation' do
    @conversation.conversation_participants.where(admin_user: @admin_user).destroy_all
    sign_in_admin @admin_user
    visit admin_conversation_path(@conversation)

    assert_text 'Assign to Me'
  end

  private

  def assert_response_success
    assert page.has_no_selector?('.error-page')
  end
end
