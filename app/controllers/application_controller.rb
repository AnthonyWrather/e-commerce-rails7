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

    # TODO: Move this to a deployment script or CI/CD pipeline
    # Honeybadger.track_deployment(
    #   environment: Rails.env,
    #   revision: `git rev-parse HEAD`.strip,
    #   local_username: `whoami`.strip,
    #   repository: "git@github.com:AnthonyWrather/e-commerce-rails7.git"
    # )
  end
end
