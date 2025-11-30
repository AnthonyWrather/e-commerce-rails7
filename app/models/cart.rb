# frozen_string_literal: true

class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy

  validates :session_token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  before_validation :set_defaults, on: :create

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :guest_carts, -> { where(user_id: nil) }
  scope :user_carts, -> { where.not(user_id: nil) }
  scope :for_user, ->(user) { where(user: user) }

  EXPIRY_DAYS = 30

  def self.find_or_create_by_token(token)
    find_by(session_token: token) || create(session_token: token)
  end

  def self.find_or_create_for_user(user, session_token: nil)
    cart = user_carts.active.for_user(user).first
    return cart if cart

    if session_token.present?
      guest_cart = find_by(session_token: session_token, user_id: nil)
      if guest_cart
        guest_cart.update!(user: user)
        return guest_cart
      end
    end

    create(user: user, session_token: SecureRandom.uuid)
  end

  def guest?
    user_id.nil?
  end

  def expired?
    expires_at <= Time.current
  end

  def extend_expiry!
    update!(expires_at: EXPIRY_DAYS.days.from_now)
  end

  def total
    cart_items.sum { |item| item.price * item.quantity }
  end

  def refresh_prices!
    cart_items.each(&:refresh_price!)
  end

  def merge_items!(other_cart_items)
    other_cart_items.each { |item| merge_single_item(item) }
  end

  def assign_to_user!(user)
    return if self.user == user

    existing_user_cart = Cart.user_carts.active.for_user(user).first
    if existing_user_cart && existing_user_cart != self
      cart_items.each do |item|
        existing_item = existing_user_cart.cart_items.find_by(product_id: item.product_id, size: item.size)
        if existing_item
          existing_item.update!(quantity: existing_item.quantity + item.quantity)
        else
          item.update!(cart: existing_user_cart)
        end
      end
      destroy!
      existing_user_cart
    else
      update!(user: user)
      self
    end
  end

  private

  def merge_single_item(incoming_item)
    product_id = extract_product_id(incoming_item)
    return unless product_id.present?

    size = incoming_item[:size] || incoming_item['size']
    quantity = (incoming_item[:quantity] || incoming_item['quantity']).to_i

    existing_item = cart_items.find_by(product_id: product_id, size: size)
    if existing_item
      existing_item.update!(quantity: existing_item.quantity + quantity)
    else
      add_new_cart_item(product_id, size, quantity, incoming_item)
    end
  end

  def extract_product_id(item)
    item[:product_id] || item['product_id'] || item[:id] || item['id']
  end

  def add_new_cart_item(product_id, size, quantity, incoming_item)
    product = Product.find_by(id: product_id)
    return unless product

    stock = size.present? ? product.stocks.find_by(size: size) : nil
    price = incoming_item[:price] || incoming_item['price'] || stock&.price || product.price

    cart_items.create!(product_id: product_id, stock: stock, size: size || '', quantity: quantity, price: price)
  end

  def set_defaults
    self.expires_at ||= EXPIRY_DAYS.days.from_now
  end
end
