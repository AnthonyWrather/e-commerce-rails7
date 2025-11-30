# frozen_string_literal: true

require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @message = messages(:message_one)
    @conversation = conversations(:conversation_one)
    @user = users(:user_one)
    @admin_user = admin_users(:admin_user_one)
  end

  # Validations
  test 'should be valid with all required attributes' do
    assert @message.valid?
  end

  test 'should require content' do
    @message.content = nil
    assert_not @message.valid?
    assert_includes @message.errors[:content], "can't be blank"
  end

  test 'should reject content longer than 5000 characters' do
    @message.content = 'a' * 5001
    assert_not @message.valid?
    assert_includes @message.errors[:content], 'is too long (maximum is 5000 characters)'
  end

  test 'should accept content of exactly 5000 characters' do
    @message.content = 'a' * 5000
    assert @message.valid?
  end

  test 'should require valid sender_type' do
    message = @conversation.messages.build(content: 'Test content', sender: @user)
    # Manually override the sender_type after building
    message.assign_attributes(sender_type: 'InvalidType')
    assert_not message.valid?
    assert_includes message.errors[:sender_type], 'is not included in the list'
  end

  test 'should allow User as sender_type' do
    message = Message.new(
      conversation: @conversation,
      sender: @user,
      content: 'Test content'
    )
    assert message.valid?
    assert_equal 'User', message.sender_type
  end

  test 'should allow AdminUser as sender_type' do
    message = Message.new(
      conversation: @conversation,
      sender: @admin_user,
      content: 'Test content'
    )
    assert message.valid?
    assert_equal 'AdminUser', message.sender_type
  end

  # Associations
  test 'should belong to conversation' do
    assert_respond_to @message, :conversation
    assert_equal @conversation, @message.conversation
  end

  test 'should belong to sender polymorphically' do
    assert_respond_to @message, :sender
    assert_equal @user, @message.sender
  end

  # Scopes
  test 'recent scope should order by created_at asc' do
    messages = Message.recent
    prev_time = nil
    messages.each do |message|
      assert prev_time.nil? || message.created_at >= prev_time
      prev_time = message.created_at
    end
  end

  test 'unread_for scope should return messages after participant last_read_at' do
    participant = conversation_participants(:participant_one)
    # Set participant's last_read_at to a past time
    participant.update!(last_read_at: 1.hour.ago)

    # Create a new message after the last_read_at
    new_message = @conversation.messages.create!(
      sender: @admin_user,
      content: 'New unread message'
    )

    unread = @conversation.messages.unread_for(participant)
    assert_includes unread, new_message
  end

  # Instance methods
  test 'sender_name should return full_name if available' do
    @message.sender = @user
    assert_equal @user.full_name, @message.sender_name
  end

  test 'sender_name should return email if no full_name' do
    @message.sender = @admin_user
    assert_equal @admin_user.email, @message.sender_name
  end

  test 'sender_name should return Unknown if sender is nil' do
    @message.sender = nil
    assert_equal 'Unknown', @message.sender_name
  end

  test 'sender_type_class should return admin for AdminUser' do
    @message.sender = @admin_user
    assert_equal 'admin', @message.sender_type_class
  end

  test 'sender_type_class should return user for User' do
    @message.sender = @user
    assert_equal 'user', @message.sender_type_class
  end

  # Callbacks
  test 'should update conversation last_message_at on create' do
    original_time = @conversation.last_message_at
    new_message = @conversation.messages.create!(
      sender: @user,
      content: 'New message'
    )
    @conversation.reload
    assert_equal new_message.created_at.to_i, @conversation.last_message_at.to_i
  end

  test 'should touch conversation on create' do
    original_updated_at = @conversation.updated_at
    sleep 0.1
    @conversation.messages.create!(
      sender: @user,
      content: 'Touch test'
    )
    @conversation.reload
    assert @conversation.updated_at > original_updated_at
  end
end
