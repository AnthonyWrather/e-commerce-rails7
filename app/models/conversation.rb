# frozen_string_literal: true

class Conversation < ApplicationRecord
  has_paper_trail

  belongs_to :user
  has_many :messages, dependent: :destroy
  has_many :conversation_participants, dependent: :destroy
  has_many :admin_users, through: :conversation_participants

  enum :status, { open: 0, active: 1, resolved: 2, closed: 3 }

  validates :user_id, presence: true
  validates :status, presence: true

  scope :recent, -> { order(updated_at: :desc) }
  scope :unresolved, -> { where(status: %i[open active]) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_admin, lambda { |admin_user_id|
    joins(:conversation_participants).where(conversation_participants: { admin_user_id: admin_user_id })
  }

  def unread_messages_for(participant)
    messages.where('created_at > ?', participant.last_read_at || created_at)
  end

  def latest_message
    messages.order(created_at: :desc).first
  end

  def participant_for(admin_user)
    conversation_participants.find_by(admin_user: admin_user)
  end
end
