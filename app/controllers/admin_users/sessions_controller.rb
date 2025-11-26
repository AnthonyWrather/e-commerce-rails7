# frozen_string_literal: true

module AdminUsers
  class SessionsController < Devise::SessionsController
    layout 'devise'
  end
end
