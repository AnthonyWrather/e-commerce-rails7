# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'scfs@southcoastfibreglass.co.uk'
  layout 'mailer'
end
