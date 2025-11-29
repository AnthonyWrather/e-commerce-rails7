# frozen_string_literal: true

class Quantities::MouldRectangleController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Quantity Calculator', :quantities_path
  add_breadcrumb 'Calculate a Rectangle Mould', :quantities_mould_rectangle_path

  def index
    permitted_params = params.permit(:length, :width, :depth, :catalyst, :material, :layers)
    result = QuantityCalculatorService.new(permitted_params).calculate_mould_rectangle

    @length = (params[:length].presence || '1.0').to_f
    @width = (params[:width].presence || '1.0').to_f
    @depth = (params[:depth].presence || '1.0').to_f
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
