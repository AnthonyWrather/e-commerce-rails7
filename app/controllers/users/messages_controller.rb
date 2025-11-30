# frozen_string_literal: true

class Users::MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :authorize_conversation_access!

  def create
    @message = @conversation.messages.build(message_params)
    @message.sender = current_user

    if @message.save
      head :ok
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def authorize_conversation_access!
    return if @conversation.user_id == current_user.id

    redirect_to conversations_path, alert: 'You are not authorized to access this conversation.'
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
