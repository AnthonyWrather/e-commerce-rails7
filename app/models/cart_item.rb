# frozen_string_literal: true

class CartItem < ApplicationRecord
  has_paper_trail

  belongs_to :cart
  belongs_to :product
  belongs_to :stock, optional: true

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: %i[cart_id size], message: 'already in cart with this size' }

  def refresh_price!
    current_price = if stock.present?
                      stock.price
                    else
                      product.price
                    end
    update!(price: current_price) if price != current_price
  end

  def name
    product.name
  end

  def total
    price * quantity
  end

  def stock_available?
    available = if stock.present?
                  stock.stock_level
                else
                  product.stock_level
                end
    available.present? && available >= quantity
  end
end
