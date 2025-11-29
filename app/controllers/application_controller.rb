# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_honeybadger_context

  protected

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_path
    else
      root_path
    end
  end

  private

  def set_honeybadger_context
    context = if defined?(current_admin_user) && current_admin_user.present?
                { user_id: current_admin_user.id, user_email: current_admin_user.email, user_type: 'admin' }
              else
                { user_id: 'guest', user_email: 'none', user_type: 'guest' }
              end
    Honeybadger.context(context)
  end
end
