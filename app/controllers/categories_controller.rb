# frozen_string_literal: true

class CategoriesController < ApplicationController
  # Setup the breadcrumbs.
  add_breadcrumb 'Home', :root_path

  # rubocop:disable Metrics/AbcSize
  def show
    @category = Category.find(params[:id])
    add_breadcrumb @category.name, :category_path
    @products = @category.products
                         .with_attached_images
                         .active
                         .in_price_range(params[:min], params[:max])
                         .in_weight_range(params[:weight_min], params[:weight_max])
    @products = @products.fiberglass_reinforcement(true) if params[:fiberglass] == '1'
    @products = @products.sorted_by(params[:sort])
    @product_count = @products.count
  end
  # rubocop:enable Metrics/AbcSize
end
