# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  layout 'devise'

  def create
    super do |user|
      merge_guest_cart_with_user_cart(user)
    end
  end

  def destroy
    create_new_guest_cart_token
    super
  end

  private

  def merge_guest_cart_with_user_cart(user)
    guest_cart = Cart.find_by(session_token: cookies[:cart_token])
    return unless guest_cart&.cart_items&.any?

    user_cart = user.carts.active.order(updated_at: :desc).first
    user_cart ||= Cart.create!(user: user, session_token: SecureRandom.uuid)

    user_cart.merge_items!(guest_cart.cart_items.map(&:attributes))
    guest_cart.destroy
    cookies.delete(:cart_token)
  end

  def create_new_guest_cart_token
    cookies[:cart_token] = {
      value: SecureRandom.uuid,
      expires: 30.days.from_now,
      httponly: true
    }
  end
end
