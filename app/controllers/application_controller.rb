# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action do
    Honeybadger.context({
                          user_id: current_user.id,
                          user_email: current_user.email
                        })
  end
end
