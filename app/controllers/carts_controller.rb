# frozen_string_literal: true

class CartsController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Shopping Cart'

  def show; end
end
