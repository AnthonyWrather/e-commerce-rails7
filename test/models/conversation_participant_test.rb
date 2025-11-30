# frozen_string_literal: true

require 'test_helper'

class ConversationParticipantTest < ActiveSupport::TestCase
  def setup
    @participant = conversation_participants(:participant_one)
    @conversation = conversations(:conversation_one)
    @admin_user = admin_users(:admin_user_one)
  end

  # Validations
  test 'should be valid with all required attributes' do
    assert @participant.valid?
  end

  test 'should require unique admin_user_id per conversation' do
    duplicate = ConversationParticipant.new(
      conversation: @conversation,
      admin_user: @admin_user
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:admin_user_id], 'has already been taken'
  end

  test 'should allow same admin_user in different conversations' do
    other_conversation = conversations(:conversation_two)
    participant = ConversationParticipant.new(
      conversation: other_conversation,
      admin_user: @admin_user
    )
    assert participant.valid?
  end

  # Associations
  test 'should belong to conversation' do
    assert_respond_to @participant, :conversation
    assert_equal @conversation, @participant.conversation
  end

  test 'should belong to admin_user' do
    assert_respond_to @participant, :admin_user
    assert_equal @admin_user, @participant.admin_user
  end

  # Scopes
  test 'active scope should return only active participants' do
    active_participants = ConversationParticipant.active
    assert active_participants.all?(&:active)
  end

  # Instance methods
  test 'mark_as_read! should update last_read_at' do
    original_time = @participant.last_read_at
    @participant.mark_as_read!
    @participant.reload
    assert @participant.last_read_at > original_time
  end

  test 'unread_count should return count of unread messages' do
    # Set last_read_at to a past time, clearing any existing unread messages
    @participant.update!(last_read_at: Time.current)
    initial_count = @participant.unread_count
    assert_equal 0, initial_count

    # Create some new messages
    2.times do |i|
      @conversation.messages.create!(
        sender: users(:user_one),
        content: "Unread message #{i}"
      )
    end

    assert_equal 2, @participant.unread_count
  end

  test 'unread_count should return 0 when all messages are read' do
    @participant.update!(last_read_at: Time.current + 1.minute)
    assert_equal 0, @participant.unread_count
  end

  test 'unread_count should count from conversation creation if last_read_at is nil' do
    @participant.update_column(:last_read_at, nil)
    # Should count all messages since conversation creation
    expected_count = @conversation.messages.count
    assert_equal expected_count, @participant.unread_count
  end

  # Default values
  test 'should have active default to true' do
    participant = ConversationParticipant.new(
      conversation: conversations(:conversation_two),
      admin_user: @admin_user
    )
    assert participant.active
  end
end
