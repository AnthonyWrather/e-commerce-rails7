class ContactController < ApplicationController
  def index
  end

  def create
    @first_name = params[:contact_form][:first_name]
    @last_name = params[:contact_form][:last_name]
    @email = params[:contact_form][:email]
    @message = params[:contact_form][:message]

    # Perform any necessary actions with the form data
    flash[:success] = "Your message has been sent successfully."
    redirect_to :contact
  end
end
