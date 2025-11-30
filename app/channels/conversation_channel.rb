# frozen_string_literal: true

class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find(params[:conversation_id])

    if authorized_for_conversation?(conversation)
      stream_for conversation
      mark_presence_online if current_admin_user
    else
      reject
    end
  rescue ActiveRecord::RecordNotFound
    reject
  end

  def unsubscribed
    mark_presence_offline if current_admin_user
  end

  def speak(data)
    conversation = Conversation.find(params[:conversation_id])
    return unless authorized_for_conversation?(conversation)

    message = conversation.messages.create!(
      sender: current_user || current_admin_user,
      content: data['message']
    )

    conversation.update!(status: :active) if current_admin_user && conversation.open?

    broadcast_message(conversation, message)
  end

  def typing(_data)
    conversation = Conversation.find(params[:conversation_id])
    return unless authorized_for_conversation?(conversation)

    ConversationChannel.broadcast_to(
      conversation,
      typing: true,
      sender_id: sender_id,
      sender_type: sender_type
    )
  end

  private

  def authorized_for_conversation?(conversation)
    (current_user && conversation.user_id == current_user.id) ||
      (current_admin_user && conversation.conversation_participants.exists?(admin_user: current_admin_user))
  end

  def mark_presence_online
    AdminPresence.mark_online(current_admin_user)
  end

  def mark_presence_offline
    AdminPresence.mark_offline(current_admin_user)
  end

  def sender_id
    current_user&.id || current_admin_user&.id
  end

  def sender_type
    current_user ? 'User' : 'AdminUser'
  end

  def broadcast_message(conversation, message)
    ConversationChannel.broadcast_to(
      conversation,
      message: render_message(message),
      sender_id: message.sender_id,
      sender_type: message.sender_type
    )
  end

  def render_message(message)
    ApplicationController.render(
      partial: 'messages/message',
      locals: { message: message }
    )
  end
end
