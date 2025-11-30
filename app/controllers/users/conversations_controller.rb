# frozen_string_literal: true

class Users::ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]
  layout 'user_dashboard'

  def index
    @conversations = current_user.conversations.recent
    @online_admin_count = AdminPresence.online.count
  end

  def show
    @messages = @conversation.messages.recent
    @message = Message.new
    @online_admin_count = AdminPresence.online.count
  end

  def new
    @conversation = Conversation.new
    @online_admin_count = AdminPresence.online.count
  end

  def create
    @conversation = current_user.conversations.build(
      status: :open,
      subject: conversation_params[:subject]
    )

    if @conversation.save
      if conversation_params[:initial_message].present?
        @conversation.messages.create!(
          sender: current_user,
          content: conversation_params[:initial_message]
        )
      end

      redirect_to conversation_path(@conversation), notice: 'Chat started. An administrator will respond shortly.'
    else
      @online_admin_count = AdminPresence.online.count
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:subject, :initial_message)
  end
end
