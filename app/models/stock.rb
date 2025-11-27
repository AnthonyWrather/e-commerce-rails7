# frozen_string_literal: true

class Stock < ApplicationRecord
  belongs_to :product

  # Validations
  validates :size, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock_level, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :weight, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :length, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :width, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :height, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
