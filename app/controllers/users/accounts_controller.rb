# frozen_string_literal: true

class Users::AccountsController < ApplicationController
  before_action :authenticate_user!
  layout 'user_dashboard'

  def show
    @user = current_user
    @recent_orders = current_user.orders.order(created_at: :desc).limit(5)
    @primary_address = current_user.primary_address
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if needs_password_update? && !@user.valid_password?(params[:user][:current_password])
      @user.errors.add(:current_password, 'is incorrect')
      render :edit, status: :unprocessable_content
      return
    end

    if @user.update(user_params)
      bypass_sign_in(@user) if params[:user][:password].present?
      redirect_to account_path, notice: 'Profile updated successfully.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    permitted = %i[full_name phone email]
    permitted += %i[password password_confirmation] if params[:user][:password].present?
    params.require(:user).permit(permitted)
  end

  def needs_password_update?
    user_params_hash = params[:user]
    return true if user_params_hash[:password].present?
    return true if user_params_hash[:email].present? && user_params_hash[:email] != current_user.email

    false
  end
end
