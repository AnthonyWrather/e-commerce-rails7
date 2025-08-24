class CategoriesController < ApplicationController
  def show
    @category = Category.find(params[:id])
    @products = @category.products
    @products = @products.where('price <= ?', params[:max]) if params[:max].present?
    return unless params[:min].present?

    @products = @products.where('price >= ?', params[:min])
  end
end
