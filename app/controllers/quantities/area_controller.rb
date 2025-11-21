# frozen_string_literal: true

class Quantities::AreaController < ApplicationController
  add_breadcrumb 'Home', :root_path
  add_breadcrumb 'Quantity Calculator', :quantities_path
  add_breadcrumb 'Calculate by Area', :quantities_area_path

  def index
    @area = (params[:area].presence || '1.0').to_f
    @catalyst = (params[:catalyst].presence || '1').to_i
    @material = params[:material].presence || ''
    # @material_width = params[:material_width].presence.to_f || 0.95
    @material_width = 0.95
    # @ratio =  params[:ratio].presence.to_f || 1.6
    @ratio = 1.6

    @layers = params[:layers].to_i

    @mat = ((@area * @layers) / @material_width).round(2)
    @mat_total = (@mat * 1.15).round(2)

    @material_weight = @material.to_i / 1000.0

    @mat_kg = ((@area * @layers) * @material_weight).round(2)
    @mat_total_kg = (@mat_kg * 1.15).round(2)

    @resin = ((@area * @layers) * @ratio).round(2)
    @resin_total = (@resin * 1.15).round(2)

    @catalyst_ml = (((@resin_total / 10) * @catalyst) * 100).round(2)

    @total_weight = (@mat_total_kg + @resin_total + (@catalyst_ml / 1000)).round(2)
  end
end
