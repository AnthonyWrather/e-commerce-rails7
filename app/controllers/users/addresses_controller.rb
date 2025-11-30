# frozen_string_literal: true

class Users::AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: %i[edit update destroy set_primary]
  layout 'user_dashboard'

  rescue_from ActiveRecord::RecordNotFound, with: :address_not_found

  def index
    @addresses = current_user.addresses.order(primary: :desc, created_at: :desc)
  end

  def new
    @address = current_user.addresses.build
  end

  def create
    @address = current_user.addresses.build(address_params)

    if @address.save
      redirect_to addresses_path, notice: 'Address added successfully.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @address.update(address_params)
      redirect_to addresses_path, notice: 'Address updated successfully.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @address.destroy
    redirect_to addresses_path, notice: 'Address deleted successfully.'
  end

  def set_primary
    @address.make_primary!
    redirect_to addresses_path, notice: 'Primary address updated successfully.'
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:label, :full_name, :line1, :line2, :city, :county, :postcode, :country, :phone,
                                    :primary)
  end

  def address_not_found
    head :not_found
  end
end
