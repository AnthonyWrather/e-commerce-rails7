# frozen_string_literal: true

class Quantities::AreaController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Quantity Calculator', :quantities_path
  add_breadcrumb 'Calculate by Area', :quantities_area_path

  def index
    result = QuantityCalculatorService.new(params.permit(:area, :catalyst, :material, :layers)).calculate_area

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
