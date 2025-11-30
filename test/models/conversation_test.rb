# frozen_string_literal: true

require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  def setup
    @conversation = conversations(:conversation_one)
    @user = users(:user_one)
    @admin_user = admin_users(:admin_user_one)
  end

  # Validations
  test 'should be valid with all required attributes' do
    assert @conversation.valid?
  end

  test 'should require user_id' do
    @conversation.user_id = nil
    assert_not @conversation.valid?
    assert_includes @conversation.errors[:user_id], "can't be blank"
  end

  test 'should require status' do
    @conversation.status = nil
    assert_not @conversation.valid?
    assert_includes @conversation.errors[:status], "can't be blank"
  end

  # Associations
  test 'should belong to user' do
    assert_respond_to @conversation, :user
    assert_equal @user, @conversation.user
  end

  test 'should have many messages' do
    assert_respond_to @conversation, :messages
  end

  test 'should have many conversation participants' do
    assert_respond_to @conversation, :conversation_participants
  end

  test 'should have many admin users through conversation participants' do
    assert_respond_to @conversation, :admin_users
  end

  test 'should destroy messages when destroyed' do
    conversation = Conversation.create!(user: @user, status: :open)
    conversation.messages.create!(sender: @user, content: 'Test message')

    assert_difference('Message.count', -1) do
      conversation.destroy
    end
  end

  test 'should destroy conversation participants when destroyed' do
    conversation = Conversation.create!(user: @user, status: :open)
    conversation.conversation_participants.create!(admin_user: @admin_user)

    assert_difference('ConversationParticipant.count', -1) do
      conversation.destroy
    end
  end

  # Enum status
  test 'should have open status by default' do
    conversation = Conversation.new(user: @user)
    assert_equal 'open', conversation.status
  end

  test 'should allow status open' do
    @conversation.status = :open
    assert @conversation.open?
  end

  test 'should allow status active' do
    @conversation.status = :active
    assert @conversation.active?
  end

  test 'should allow status resolved' do
    @conversation.status = :resolved
    assert @conversation.resolved?
  end

  test 'should allow status closed' do
    @conversation.status = :closed
    assert @conversation.closed?
  end

  # Scopes
  test 'recent scope should order by updated_at desc' do
    conversations = Conversation.recent
    assert_equal conversations.first.updated_at, conversations.maximum(:updated_at)
  end

  test 'unresolved scope should return open and active conversations' do
    unresolved = Conversation.unresolved
    assert unresolved.all? { |c| c.open? || c.active? }
  end

  test 'for_user scope should return conversations for a specific user' do
    user_conversations = Conversation.for_user(@user.id)
    assert user_conversations.all? { |c| c.user_id == @user.id }
  end

  test 'for_admin scope should return conversations for a specific admin' do
    admin_conversations = Conversation.for_admin(@admin_user.id)
    assert admin_conversations.all? { |c| c.conversation_participants.exists?(admin_user_id: @admin_user.id) }
  end

  # Instance methods
  test 'unread_messages_for should return messages after last_read_at' do
    participant = conversation_participants(:participant_one)
    unread = @conversation.unread_messages_for(participant)
    assert unread.all? { |m| m.created_at > participant.last_read_at }
  end

  test 'latest_message should return most recent message' do
    latest = @conversation.latest_message
    if @conversation.messages.any?
      assert_equal @conversation.messages.order(created_at: :desc).first, latest
    else
      assert_nil latest
    end
  end

  test 'participant_for should find participant for admin user' do
    participant = @conversation.participant_for(@admin_user)
    assert_equal @admin_user, participant&.admin_user
  end

  # Paper Trail
  test 'should enable paper_trail auditing' do
    assert Conversation.respond_to?(:paper_trail)
  end

  test 'should create version on update' do
    @conversation.update!(subject: 'Updated subject')
    assert @conversation.versions.any?
  end
end
