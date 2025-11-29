# frozen_string_literal: true

class Product < ApplicationRecord
  include PgSearch::Model

  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
    attachable.variant :thumb_webp, resize_to_limit: [50, 50], format: :webp
    attachable.variant :medium, resize_to_limit: [250, 250]
    attachable.variant :medium_webp, resize_to_limit: [250, 250], format: :webp
  end

  belongs_to :category
  has_many :stocks
  has_many :order_products

  # Full-text search scope using pg_search
  pg_search_scope :search_by_text,
                  against: {
                    name: 'A',
                    description: 'B'
                  },
                  associated_against: {
                    category: [:name]
                  },
                  using: {
                    tsearch: {
                      prefix: true,
                      dictionary: 'english',
                      highlight: {
                        StartSel: '<mark>',
                        StopSel: '</mark>',
                        MaxWords: 35,
                        MinWords: 15
                      }
                    }
                  }

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
