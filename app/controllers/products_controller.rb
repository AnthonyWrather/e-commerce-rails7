# frozen_string_literal: true

class ProductsController < ApplicationController
  add_breadcrumb 'Home', :root_path

  def show
    # Eager load category and stocks to prevent N+1 queries
    @product = Product.includes(:category, :stocks).find(params[:id])
    @stocks = @product.stocks
    add_breadcrumb @product.category.name, category_path(@product.category.id)
    add_breadcrumb @product.name, product_path(@product.id)
  end
end
