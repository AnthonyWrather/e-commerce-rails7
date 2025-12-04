# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  include FlashMessageSanitizer

  before_action :set_honeybadger_context
  before_action :set_paper_trail_whodunnit
  before_action :set_honeybadger_user_context

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

  def set_honeybadger_user_context
    if defined?(current_user) && respond_to?(:current_user, true)
      Honeybadger.context({
                            user_id: current_user.try(:id) || 'Guest',
                            user_email: current_user.try(:email) || 'none@guest.com'
                          })
    else
      Honeybadger.context({
                            user_id: 'Guest',
                            user_email: 'none@guest.com'
                          })
    end
  end

  def set_honeybadger_context
    context = if respond_to?(:current_admin_user, true) && current_admin_user.present?
                { user_id: current_admin_user.id, user_email: current_admin_user.email, user_type: 'admin' }
              else
                { user_id: 'guest', user_email: 'none', user_type: 'guest' }
              end
    Honeybadger.context(context)
  end
end
