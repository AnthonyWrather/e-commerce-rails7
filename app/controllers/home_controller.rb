# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @main_categories = Category.take(4)
  end
end
