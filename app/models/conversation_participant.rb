# frozen_string_literal: true

class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :admin_user

  validates :admin_user_id, uniqueness: { scope: :conversation_id }

  scope :active, -> { where(active: true) }

  def mark_as_read!
    update!(last_read_at: Time.current)
  end

  def unread_count
    conversation.messages.where('created_at > ?', last_read_at || conversation.created_at).count
  end
end
