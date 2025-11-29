# frozen_string_literal: true

class Quantities::DimensionsController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Quantity Calculator', :quantities_path
  add_breadcrumb 'Calculate by Dimensions', :quantities_dimensions_path

  def index
    permitted_params = params.permit(:length, :width, :catalyst, :material, :layers)
    result = QuantityCalculatorService.new(permitted_params).calculate_dimensions

    @length = (params[:length].presence || '1.0').to_f
    @width = (params[:width].presence || '1.0').to_f
    @depth = 0
    @area = result.area
    @catalyst = result.catalyst
    @material = result.material
    @material_width = result.material_width
    @ratio = result.ratio
    @layers = result.layers
    @mat = result.mat
    @mat_total = result.mat_total
    @material_weight = result.material_weight
    @mat_kg = result.mat_kg
    @mat_total_kg = result.mat_total_kg
    @resin = result.resin
    @resin_total = result.resin_total
    @catalyst_ml = result.catalyst_ml
    @total_weight = result.total_weight
  end
end
