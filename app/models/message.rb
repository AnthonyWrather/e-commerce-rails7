# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation, touch: :last_message_at
  belongs_to :sender, polymorphic: true

  validates :content, presence: true, length: { maximum: 5000 }
  validates :sender_type, inclusion: { in: %w[User AdminUser] }

  scope :recent, -> { order(created_at: :asc) }
  scope :unread_for, lambda { |participant|
    where('created_at > ?', participant.last_read_at || Time.zone.at(0))
  }

  after_create_commit :update_conversation_timestamp

  def sender_name
    sender.try(:full_name) || sender.try(:email) || 'Unknown'
  end

  def sender_type_class
    sender_type == 'AdminUser' ? 'admin' : 'user'
  end

  private

  def update_conversation_timestamp
    conversation.update_column(:last_message_at, created_at)
  end
end
