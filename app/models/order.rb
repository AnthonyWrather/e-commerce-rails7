# frozen_string_literal: true

class Order < ApplicationRecord
  has_many :order_products

  # Validations
  validates :customer_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :total, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :shipping_cost, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :address, presence: true
  validates :name, presence: true
end
