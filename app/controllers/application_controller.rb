# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action do
    if current_user && current_user.exists?
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
end
