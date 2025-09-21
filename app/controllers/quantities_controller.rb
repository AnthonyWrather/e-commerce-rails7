class QuantitiesController < ApplicationController
  def index
    @area = (params[:length].to_f * params[:width].to_f).round(2)
    @layers = params[:layers].to_i

    @mat = ((@area * @layers) / 1.3).round(2)
    @mat_total = (@mat * 1.15).round(2)

    # Need to set the Mat Weight and Type values.
    @mat_type = "600g CSM"
    @mat_weight = 0.6
    @mat_resin = 1.5

    @mat_kg = ((@area * @layers) * @mat_weight).round(2)
    @mat_total_kg = (@mat_kg * 1.15).round(2)

    @resin = ((@area * @layers) * @mat_resin).round(2)
    @resin_total = (@resin * 1.15).round(2)

    @catalyst = params[:catalyst].to_i
    @catalyst_ml = (((@resin_total / 10) * @catalyst) * 100).round(2)

    @total_weight = (@mat_total_kg + @resin_total + (@catalyst_ml / 1000)).round(2)
  end
end
