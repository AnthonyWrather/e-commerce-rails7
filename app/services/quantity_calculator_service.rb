# frozen_string_literal: true

class QuantityCalculatorService
  include QuantityCalculatorConstants

  Result = Struct.new(
    :area, :layers, :material, :material_width, :ratio, :mat, :mat_total,
    :material_weight, :mat_kg, :mat_total_kg, :resin, :resin_total,
    :catalyst_ml, :total_weight, :catalyst,
    keyword_init: true
  )

  def initialize(params = {})
    @params = params
  end

  def calculate_area
    area = params_fetch(:area, '1.0').to_f
    layers = params_fetch(:layers, 0).to_i
    catalyst = params_fetch(:catalyst, '1').to_i
    material = params_fetch(:material, '')

    calculate_quantities(area: area, layers: layers, catalyst: catalyst, material: material)
  end

  def calculate_dimensions
    length = params_fetch(:length, '1.0').to_f
    width = params_fetch(:width, '1.0').to_f
    depth = 0
    layers = params_fetch(:layers, 0).to_i
    catalyst = params_fetch(:catalyst, '1').to_i
    material = params_fetch(:material, '')

    area = calculate_surface_area(length, width, depth)

    calculate_quantities(area: area, layers: layers, catalyst: catalyst, material: material)
  end

  def calculate_mould_rectangle
    length = params_fetch(:length, '1.0').to_f
    width = params_fetch(:width, '1.0').to_f
    depth = params_fetch(:depth, '1.0').to_f
    layers = params_fetch(:layers, 0).to_i
    catalyst = params_fetch(:catalyst, '1').to_i
    material = params_fetch(:material, '')

    area = calculate_surface_area(length, width, depth)

    calculate_quantities(area: area, layers: layers, catalyst: catalyst, material: material)
  end

  private

  def params_fetch(key, default)
    value = @params[key]
    value.presence || default
  end

  def calculate_surface_area(length, width, depth)
    ((length * width) + (2 * (length * depth)) + (2 * (width * depth))).round(2)
  end

  def calculate_quantities(area:, layers:, catalyst:, material:)
    material_weight = material.to_i / 1000.0

    mat = ((area * layers) / MATERIAL_WIDTH).round(2)
    mat_total = (mat * WASTAGE_FACTOR).round(2)

    mat_kg = ((area * layers) * material_weight).round(2)
    mat_total_kg = (mat_kg * WASTAGE_FACTOR).round(2)

    resin = ((area * layers) * RESIN_TO_GLASS_RATIO).round(2)
    resin_total = (resin * WASTAGE_FACTOR).round(2)

    catalyst_ml = (((resin_total / 10) * catalyst) * 100).round(2)

    total_weight = (mat_total_kg + resin_total + (catalyst_ml / 1000)).round(2)

    Result.new(
      area: area,
      layers: layers,
      material: material,
      material_width: MATERIAL_WIDTH,
      ratio: RESIN_TO_GLASS_RATIO,
      mat: mat,
      mat_total: mat_total,
      material_weight: material_weight,
      mat_kg: mat_kg,
      mat_total_kg: mat_total_kg,
      resin: resin,
      resin_total: resin_total,
      catalyst_ml: catalyst_ml,
      total_weight: total_weight,
      catalyst: catalyst
    )
  end
end
