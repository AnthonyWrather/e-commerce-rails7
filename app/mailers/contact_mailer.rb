# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact_email(first_name:, last_name:, email:, message:)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @message = message

    mail(
      to: ENV.fetch('ADMIN_EMAIL', 'admin@cariana.tech'),
      subject: "Contact Form Submission from #{first_name} #{last_name}",
      reply_to: email
    )
  end
end
