# frozen_string_literal: true

class CartPersistenceService
  class PersistenceError < StandardError; end

  attr_reader :cart

  def initialize(session_token)
    @session_token = session_token
    @cart = find_or_create_cart
  end

  def sync_from_local_storage(cart_items_data)
    ActiveRecord::Base.transaction do
      cart_items_data.each do |item_data|
        sync_item(item_data)
      end
      cart.extend_expiry!
    end
    cart.reload
  rescue StandardError => e
    Rails.logger.error("Cart sync failed: #{e.message}")
    raise PersistenceError, "Failed to sync cart: #{e.message}"
  end

  def load_cart
    return nil if cart.nil? || cart.expired?

    cart.refresh_prices!
    cart
  end

  def to_local_storage_format
    return [] if cart.nil?

    cart.cart_items.includes(:product, :stock).map do |item|
      {
        id: item.product_id,
        name: item.product.name,
        price: item.price,
        size: item.size || '',
        quantity: item.quantity
      }
    end
  end

  def merge_carts(incoming_items)
    cart.merge_items!(incoming_items)
    cart.extend_expiry!
    cart.reload
  end

  def clear_cart
    cart.cart_items.destroy_all
  end

  private

  def find_or_create_cart
    Cart.find_or_create_by_token(@session_token)
  end

  def sync_item(item_data)
    product = Product.find_by(id: item_data['id'] || item_data[:id])
    return unless product

    size = item_data['size'] || item_data[:size]
    quantity = (item_data['quantity'] || item_data[:quantity]).to_i
    stock = find_stock(product, size)
    price = stock&.price || product.price

    existing_item = cart.cart_items.find_by(product_id: product.id, size: size)

    if existing_item
      existing_item.update!(quantity: quantity, price: price)
    else
      cart.cart_items.create!(
        product: product,
        stock: stock,
        size: size || '',
        quantity: quantity,
        price: price
      )
    end
  end

  def find_stock(product, size)
    return nil if size.blank?

    product.stocks.find_by(size: size)
  end
end
