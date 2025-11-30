# frozen_string_literal: true

require 'test_helper'

class Admin::ConversationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin_user = admin_users(:admin_user_one)
    @conversation = conversations(:conversation_one)
    sign_in @admin_user
  end

  test 'should get index' do
    get admin_conversations_url
    assert_response :success
    assert_select 'h1', /Chat Dashboard/
  end

  test 'should filter conversations by status' do
    get admin_conversations_url(status: 'open')
    assert_response :success

    get admin_conversations_url(status: 'active')
    assert_response :success

    get admin_conversations_url(status: 'resolved')
    assert_response :success

    get admin_conversations_url(status: 'closed')
    assert_response :success
  end

  test 'should get show when admin is assigned' do
    ConversationParticipant.find_or_create_by(
      conversation: @conversation,
      admin_user: @admin_user
    )

    get admin_conversation_url(@conversation)
    assert_response :success
    assert_select 'h1', @conversation.subject.presence || "Chat ##{@conversation.id}"
  end

  test 'should assign conversation to admin' do
    conversation = conversations(:conversation_two)
    conversation.conversation_participants.where(admin_user: @admin_user).destroy_all

    assert_difference 'ConversationParticipant.count', 1 do
      post assign_admin_conversation_url(conversation)
    end

    assert_redirected_to admin_conversation_path(conversation)
    assert_equal 'Conversation assigned to you.', flash[:notice]
    assert conversation.reload.conversation_participants.exists?(admin_user: @admin_user)
  end

  test 'assign should update open conversation status to active' do
    open_conversation = conversations(:conversation_one)
    open_conversation.update!(status: :open)
    open_conversation.conversation_participants.destroy_all

    post assign_admin_conversation_url(open_conversation)

    assert_equal 'active', open_conversation.reload.status
  end

  test 'should resolve conversation' do
    active_conversation = conversations(:conversation_two)
    active_conversation.update!(status: :active)

    patch resolve_admin_conversation_url(active_conversation)

    assert_redirected_to admin_conversations_path
    assert_equal 'Conversation marked as resolved.', flash[:notice]
    assert_equal 'resolved', active_conversation.reload.status
  end

  test 'should close conversation' do
    active_conversation = conversations(:conversation_two)

    patch close_admin_conversation_url(active_conversation)

    assert_redirected_to admin_conversations_path
    assert_equal 'Conversation closed.', flash[:notice]
    assert_equal 'closed', active_conversation.reload.status
  end

  test 'should toggle availability to online' do
    AdminPresence.where(admin_user: @admin_user).destroy_all

    post admin_toggle_availability_conversations_url

    assert_redirected_to admin_conversations_path
    assert_match(/Status updated to/, flash[:notice])

    presence = AdminPresence.find_by(admin_user: @admin_user)
    assert presence.present?
  end

  test 'should toggle availability from online to offline' do
    AdminPresence.find_or_create_by(admin_user: @admin_user) do |p|
      p.status = 'online'
      p.last_seen_at = Time.current
    end

    post admin_toggle_availability_conversations_url

    assert_redirected_to admin_conversations_path
    presence = AdminPresence.find_by(admin_user: @admin_user)
    assert_equal 'offline', presence.status
  end

  test 'should require authentication' do
    sign_out @admin_user

    get admin_conversations_url
    assert_redirected_to new_admin_user_session_path
  end

  test 'index shows my conversations section when assigned' do
    ConversationParticipant.find_or_create_by(
      conversation: @conversation,
      admin_user: @admin_user
    )

    get admin_conversations_url
    assert_response :success
    assert_select 'h2', /My Conversations/
  end

  test 'show marks participant as read' do
    participant = ConversationParticipant.find_or_create_by(
      conversation: @conversation,
      admin_user: @admin_user
    )
    participant.update!(last_read_at: 1.day.ago)
    old_last_read = participant.last_read_at

    get admin_conversation_url(@conversation)

    participant.reload
    assert participant.last_read_at > old_last_read
  end
end
