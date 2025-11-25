# frozen_string_literal: true

class CategoriesController < ApplicationController
  # Setup the breadcrumbs.
  add_breadcrumb 'Home', :root_path

  def show
    @category = Category.find(params[:id])
    add_breadcrumb @category.name, :category_path
    @products = @category.products.with_attached_images
    @products = @products.where(active: true)
    @products = @products.where('price <= ?', params[:max]) if params[:max].present?
    return unless params[:min].present?

    @products = @products.where('price >= ?', params[:min])
  end
end
