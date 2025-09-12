# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  # TODO: Change to real email.
  # default from: 'scfs@southcoastfibreglass.co.uk'
  default from: 'scfs@cariana.tech'
  layout 'mailer'
end
