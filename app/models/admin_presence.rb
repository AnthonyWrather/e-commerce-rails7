# frozen_string_literal: true

class AdminPresence < ApplicationRecord
  belongs_to :admin_user

  validates :admin_user_id, uniqueness: true
  validates :status, inclusion: { in: %w[online away offline] }

  scope :online, -> { where(status: 'online') }
  scope :available, -> { where(status: %w[online away]) }

  after_commit :broadcast_status_change, if: :saved_change_to_status?

  def self.mark_online(admin_user)
    find_or_initialize_by(admin_user: admin_user).tap do |presence|
      presence.status = 'online'
      presence.last_seen_at = Time.current
      presence.save!
    end
  end

  def self.mark_offline(admin_user)
    find_by(admin_user: admin_user)&.update(status: 'offline', last_seen_at: Time.current)
  end

  private

  def broadcast_status_change
    PresenceChannel.broadcast_presence_update(self)
  end
end
