# frozen_string_literal: true

class SearchController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Search', :search_path

  def index
    set_search_params
    search_products
    @categories = Category.joins(:products).distinct.order(:name)
  end

  private

  def set_search_params
    @query = params[:q].to_s.strip
    @min_price = params[:min]
    @max_price = params[:max]
    @category_id = params[:category_id]
  end

  def search_products
    if @query.present?
      @products = build_search_query
      @pagy, @products = pagy(@products, limit: 12)
    else
      @products = Product.none
      @pagy = nil
    end
  end

  def build_search_query
    base_query = Product.search_by_text(@query)
                        .includes(:category)
                        .with_attached_images
                        .active
                        .in_price_range(@min_price, @max_price)

    @category_id.present? ? base_query.where(category_id: @category_id) : base_query
  end
end
