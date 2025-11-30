# frozen_string_literal: true

class Admin::MessagesController < AdminController
  before_action :set_conversation
  before_action :authorize_admin_access!

  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_admin_user

    if @message.save
      @conversation.update!(status: :active) if @conversation.open?
      head :ok
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def authorize_admin_access!
    participant = @conversation.conversation_participants.find_by(admin_user: current_admin_user)
    return if participant.present?

    redirect_to admin_conversations_path, alert: 'You must be assigned to this conversation to send messages.'
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
