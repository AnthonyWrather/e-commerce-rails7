# frozen_string_literal: true

class HomeController < ApplicationController
  add_breadcrumb 'Home', :root_path

  def index
    # Eager load image attachment to prevent N+1 queries
    @main_categories = Category.includes(image_attachment: :blob).take(10)
  end
end
