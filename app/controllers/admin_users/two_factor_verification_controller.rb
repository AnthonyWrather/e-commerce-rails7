# frozen_string_literal: true

class AdminUsers::TwoFactorVerificationController < ApplicationController
  before_action :redirect_if_no_pending_verification
  layout 'devise'

  # GET /admin_users/two_factor_verification/new - Show OTP verification form
  def new
    @user_id = session[:otp_user_id]
  end

  # POST /admin_users/two_factor_verification - Verify OTP code
  def create
    user = AdminUser.find_by(id: session[:otp_user_id])

    unless user
      session.delete(:otp_user_id)
      redirect_to new_admin_user_session_path, alert: 'Session expired. Please sign in again.'
      return
    end

    if valid_otp?(user, params[:otp_attempt])
      complete_sign_in(user)
    elsif user.validate_backup_code(params[:otp_attempt])
      complete_sign_in(user, backup_code_used: true)
    else
      flash.now[:alert] = 'Invalid verification code. Please try again.'
      @user_id = session[:otp_user_id]
      render :new, status: :unprocessable_entity
    end
  end

  private

  def redirect_if_no_pending_verification
    return if session[:otp_user_id].present?

    redirect_to new_admin_user_session_path
  end

  def valid_otp?(user, otp_attempt)
    return false if otp_attempt.blank?

    user.validate_and_consume_otp!(otp_attempt)
  end

  def complete_sign_in(user, backup_code_used: false)
    session.delete(:otp_user_id)
    sign_in(:admin_user, user)

    if backup_code_used
      remaining_codes = user.otp_backup_codes&.count || 0
      message = 'Signed in with backup code. '
      message += if remaining_codes.zero?
                   'No backup codes remaining. Please generate new codes.'
                 else
                   "#{remaining_codes} backup #{'code'.pluralize(remaining_codes)} remaining."
                 end
      redirect_to admin_root_path, notice: message
    else
      redirect_to admin_root_path, notice: 'Signed in successfully.'
    end
  end
end
