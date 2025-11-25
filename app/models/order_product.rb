# frozen_string_literal: true

class OrderProduct < ApplicationRecord
  belongs_to :product
  belongs_to :order

  # Validations
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
