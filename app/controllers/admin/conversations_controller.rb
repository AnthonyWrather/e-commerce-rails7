# frozen_string_literal: true

class Admin::ConversationsController < AdminController
  before_action :set_conversation, only: %i[show assign resolve close]

  def index
    @filter = params[:status].presence
    @conversations = filtered_conversations
    @assigned_conversations = Conversation.for_admin(current_admin_user.id).recent
    @online_admins = AdminPresence.online.includes(:admin_user)
    @current_admin_presence = current_admin_user.admin_presence
  end

  def show
    @messages = @conversation.messages.recent
    @message = Message.new

    @participant = @conversation.conversation_participants.find_or_create_by(
      admin_user: current_admin_user
    )
    @participant.mark_as_read!
  end

  def assign
    @conversation.conversation_participants.find_or_create_by(
      admin_user: current_admin_user
    )
    @conversation.update!(status: :active) if @conversation.open?

    redirect_to admin_conversation_path(@conversation), notice: 'Conversation assigned to you.'
  end

  def resolve
    @conversation.update!(status: :resolved)
    redirect_to admin_conversations_path, notice: 'Conversation marked as resolved.'
  end

  def close
    @conversation.update!(status: :closed)
    redirect_to admin_conversations_path, notice: 'Conversation closed.'
  end

  def toggle_availability
    presence = AdminPresence.find_or_initialize_by(admin_user: current_admin_user)
    presence.status = presence.status == 'online' ? 'offline' : 'online'
    presence.last_seen_at = Time.current
    presence.save!

    redirect_to admin_conversations_path, notice: "Status updated to #{presence.status}."
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def filtered_conversations
    base_scope = Conversation.recent.includes(:user, :messages)

    case @filter
    when 'open'
      base_scope.open
    when 'active'
      base_scope.active
    when 'resolved'
      base_scope.resolved
    when 'closed'
      base_scope.closed
    else
      base_scope.unresolved
    end
  end
end
