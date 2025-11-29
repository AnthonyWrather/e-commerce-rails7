# frozen_string_literal: true

class SearchController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Search', :search_path

  def index
    @query = params[:q].to_s.strip
    @min_price = params[:min]
    @max_price = params[:max]
    @category_id = params[:category_id]

    if @query.present?
      @products = Product.search_by_text(@query)
                         .includes(:category)
                         .with_attached_images
                         .active
                         .in_price_range(@min_price, @max_price)

      @products = @products.where(category_id: @category_id) if @category_id.present?

      @pagy, @products = pagy(@products, limit: 12)
    else
      @products = Product.none
      @pagy = nil
    end

    @categories = Category.joins(:products).distinct.order(:name)
  end
end
