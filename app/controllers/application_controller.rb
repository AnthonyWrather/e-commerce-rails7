# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_honeybadger_context
  before_action :set_paper_trail_whodunnit

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

  def user_for_paper_trail
    current_admin_user&.email || 'System'
  end

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
    context = if respond_to?(:current_admin_user, true) && current_admin_user.present?
                { user_id: current_admin_user.id, user_email: current_admin_user.email, user_type: 'admin' }
              else
                { user_id: 'guest', user_email: 'none', user_type: 'guest' }
              end
    Honeybadger.context(context)
  end
end
