# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout 'devise'

  def create
    super do |user|
      transfer_guest_cart_to_user(user) if user.persisted?
    end
  end

  protected

  def after_sign_up_path_for(_resource)
    root_path
  end

  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end

  private

  def transfer_guest_cart_to_user(user)
    guest_cart = Cart.find_by(session_token: cookies[:cart_token])
    return unless guest_cart

    guest_cart.assign_to_user!(user)
    cookies.delete(:cart_token)
  end

  def sign_up_params
    params.require(:user).permit(:full_name, :phone, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:full_name, :phone, :email, :password, :password_confirmation, :current_password)
  end
end
