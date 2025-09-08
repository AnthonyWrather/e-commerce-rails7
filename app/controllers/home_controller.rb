# frozen_string_literal: true

class HomeController < ApplicationController
  add_breadcrumb 'Home', :root_path

  def index
    @main_categories = Category.take(10)
  end
end
