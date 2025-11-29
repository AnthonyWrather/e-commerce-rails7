# frozen_string_literal: true

class Product < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
    attachable.variant :thumb_webp, resize_to_limit: [50, 50], format: :webp
    attachable.variant :medium, resize_to_limit: [250, 250]
    attachable.variant :medium_webp, resize_to_limit: [250, 250], format: :webp
  end

  belongs_to :category
  has_many :stocks
  has_many :order_products

  # Scopes for filtering products
  scope :active, -> { where(active: true) }
  scope :in_price_range, lambda { |min, max|
    relation = all
    relation = relation.where('price >= ?', min) if min.present?
    relation = relation.where('price <= ?', max) if max.present?
    relation
  }

  # Validations
  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock_level, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :shipping_weight, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :shipping_length, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :shipping_width, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :shipping_height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
