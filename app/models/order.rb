# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :order_products

  # Scopes for filtering orders
  scope :unfulfilled, -> { where(fulfilled: false) }
  scope :fulfilled, -> { where(fulfilled: true) }
  scope :recent, ->(limit = 5) { order(created_at: :desc).limit(limit) }
  scope :for_month, ->(date = Time.current) { where(created_at: date.beginning_of_month..date.end_of_month) }

  # Validations
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :total, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :shipping_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :address, presence: true
  validates :name, presence: true
end
