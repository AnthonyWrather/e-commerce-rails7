# frozen_string_literal: true

class ContactController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Contact Us', :contact_path

  def index; end

  def create
    errors = validate_contact_params

    if errors.any?
      flash[:error] = errors.join(', ')
      redirect_to :contact
      return
    end

    ContactMailer.contact_email(
      first_name: contact_params[:first_name],
      last_name: contact_params[:last_name],
      email: contact_params[:email],
      message: contact_params[:message]
    ).deliver_later

    flash[:success] = 'Your message has been sent successfully.'
    redirect_to :contact
  end

  private

  def contact_params
    params.require(:contact_form).permit(:first_name, :last_name, :email, :message)
  end

  def validate_contact_params
    errors = []
    errors << 'First name is required' if contact_params[:first_name].blank?
    errors << 'Last name is required' if contact_params[:last_name].blank?
    errors << 'Email is required' if contact_params[:email].blank?
    errors << 'Message is required' if contact_params[:message].blank?

    if contact_params[:email].present? && !valid_email?(contact_params[:email])
      errors << 'Email format is invalid'
    end

    errors
  end

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i)
  end
end
