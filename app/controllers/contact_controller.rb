# frozen_string_literal: true

class ContactController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Contact Us', :contact_path

  def index; end

  def create
    @first_name = params[:contact_form][:first_name]
    @last_name = params[:contact_form][:last_name]
    @email = params[:contact_form][:email]
    @message = params[:contact_form][:message]

    # Perform any necessary actions with the form data
    flash[:success] = 'Your message has been sent successfully.'
    redirect_to :contact
  end
end
