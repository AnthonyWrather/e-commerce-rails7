# frozen_string_literal: true

class Category < ApplicationRecord
  has_paper_trail

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
    attachable.variant :thumb_webp, resize_to_limit: [50, 50], format: :webp
    attachable.variant :display, resize_to_limit: [512, 512]
    attachable.variant :display_webp, resize_to_limit: [512, 512], format: :webp
  end

  has_many :products, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
