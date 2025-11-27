# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action do
    if defined?(current_user)
      Honeybadger.context({
                            user_id: current_user.id.exists? ? current_user.id : 'Guest',
                            user_email: current_user.email.exists? ? current_user.email : 'none@guest.com'
                          })
    else
      Honeybadger.context({
                            user_id: 'Guest',
                            user_email: 'none@guest.com'
                          })
    end
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_path
    else
      root_path
    end
  end
end
