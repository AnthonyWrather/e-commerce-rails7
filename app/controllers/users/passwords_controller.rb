# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  layout 'devise'

  protected

  def after_resetting_password_path_for(_resource)
    new_user_session_path
  end

  def after_sending_reset_password_instructions_path_for(_resource_name)
    new_user_session_path
  end
end
