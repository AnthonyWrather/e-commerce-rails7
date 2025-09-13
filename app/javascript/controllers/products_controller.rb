# frozen_string_literal: true

class ProductsController < ApplicationController
  add_breadcrumb 'Home', :root_path

  def show
    @product = Product.find(params[:id])
    @stocks = @product.stocks
    add_breadcrumb @product.category.name, category_path(@product.category.id)
    add_breadcrumb @product.name, product_path(@product.id)
  end
end
