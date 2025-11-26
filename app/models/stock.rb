# frozen_string_literal: true

class Stock < ApplicationRecord
  belongs_to :product

  # Validations
  validates :size, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock_level, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :shipping_weight, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :shipping_length, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :shipping_width, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :shipping_height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
