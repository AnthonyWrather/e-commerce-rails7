# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  has_many :carts, dependent: :nullify
  has_many :addresses, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  validates :full_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :phone, format: { with: /\A[\d\s+\-()]+\z/, message: 'only allows numbers, spaces, and +/-()' },
                    allow_blank: true

  def display_name
    full_name.presence || email.split('@').first
  end
end
