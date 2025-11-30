# frozen_string_literal: true

module AdminUsers
  class SessionsController < Devise::SessionsController
    layout 'devise'

    # Override Devise's create action to handle 2FA
    def create
      self.resource = warden.authenticate!(auth_options)

      if resource.two_factor_enabled?
        # Store user ID in session for 2FA verification
        sign_out(resource)
        session[:otp_user_id] = resource.id
        redirect_to new_admin_users_two_factor_verification_path
      else
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    end
  end
end
