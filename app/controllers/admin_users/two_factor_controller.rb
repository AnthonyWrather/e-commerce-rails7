# frozen_string_literal: true

class AdminUsers::TwoFactorController < ApplicationController
  before_action :authenticate_admin_user!
  layout 'devise'

  # GET /admin_users/two_factor/new - Show 2FA setup page with QR code
  def new
    if current_admin_user.two_factor_enabled?
      redirect_to admin_root_path, notice: 'Two-factor authentication is already enabled.'
      return
    end

    # Generate a new OTP secret if not already pending
    current_admin_user.setup_two_factor! unless current_admin_user.two_factor_pending?

    @qr_code = generate_qr_code
    @otp_secret = format_otp_secret(current_admin_user.otp_secret)
  end

  # POST /admin_users/two_factor - Enable 2FA with verification code
  def create
    if current_admin_user.enable_two_factor!(params[:otp_attempt])
      @backup_codes = current_admin_user.otp_backup_codes
      flash.now[:notice] = 'Two-factor authentication has been enabled successfully.'
      render :backup_codes
    else
      current_admin_user.setup_two_factor! unless current_admin_user.two_factor_pending?
      @qr_code = generate_qr_code
      @otp_secret = format_otp_secret(current_admin_user.otp_secret)
      flash.now[:alert] = 'Invalid verification code. Please try again.'
      render :new, status: :unprocessable_content
    end
  end

  # GET /admin_users/two_factor/edit - Show 2FA management page
  def edit
    unless current_admin_user.two_factor_enabled?
      redirect_to new_admin_users_two_factor_path, notice: 'Please enable two-factor authentication first.'
      return
    end

    @backup_codes_count = current_admin_user.otp_backup_codes&.count || 0
  end

  # DELETE /admin_users/two_factor - Disable 2FA with password confirmation
  def destroy
    if current_admin_user.disable_two_factor!(params[:password])
      redirect_to admin_root_path, notice: 'Two-factor authentication has been disabled.'
    else
      @backup_codes_count = current_admin_user.otp_backup_codes&.count || 0
      flash.now[:alert] = 'Invalid password. Please try again.'
      render :edit, status: :unprocessable_content
    end
  end

  # POST /admin_users/two_factor/regenerate_backup_codes - Generate new backup codes
  def regenerate_backup_codes
    unless current_admin_user.two_factor_enabled?
      redirect_to new_admin_users_two_factor_path, alert: 'Please enable two-factor authentication first.'
      return
    end

    current_admin_user.regenerate_backup_codes!
    @backup_codes = current_admin_user.otp_backup_codes
    flash.now[:notice] = 'New backup codes have been generated. Please save them securely.'
    render :backup_codes
  end

  private

  def generate_qr_code
    qrcode = RQRCode::QRCode.new(current_admin_user.otp_provisioning_uri)
    qrcode.as_svg(
      offset: 0,
      color: '000',
      shape_rendering: 'crispEdges',
      module_size: 4,
      standalone: true
    )
  end

  def format_otp_secret(secret)
    return '' if secret.blank?

    # Format secret in groups of 4 for easier manual entry
    secret.scan(/.{1,4}/).join(' ')
  end
end
