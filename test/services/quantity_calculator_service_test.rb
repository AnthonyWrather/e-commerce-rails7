# frozen_string_literal: true

require 'test_helper'

class QuantityCalculatorServiceTest < ActiveSupport::TestCase
  test 'QuantityCalculatorService class exists' do
    assert QuantityCalculatorService
  end

  test 'QuantityCalculatorConstants module exists' do
    assert QuantityCalculatorConstants
  end

  test 'constants have expected values' do
    assert_equal 0.95, QuantityCalculatorConstants::MATERIAL_WIDTH
    assert_equal 1.6, QuantityCalculatorConstants::RESIN_TO_GLASS_RATIO
    assert_equal 1.15, QuantityCalculatorConstants::WASTAGE_FACTOR
  end

  test 'calculate_area uses default values when no parameters provided' do
    service = QuantityCalculatorService.new
    result = service.calculate_area

    assert_equal 1.0, result.area
    assert_equal 1, result.catalyst
    assert_equal '', result.material
    assert_equal 0.95, result.material_width
    assert_equal 1.6, result.ratio
    assert_equal 0, result.layers
  end

  test 'calculate_area calculates mat with given area and layers' do
    service = QuantityCalculatorService.new(area: 10, layers: 2)
    result = service.calculate_area

    assert_equal 21.05, result.mat
    assert_equal 24.21, result.mat_total
  end

  test 'calculate_area calculates material weight in kg' do
    service = QuantityCalculatorService.new(area: 5, layers: 3, material: '300')
    result = service.calculate_area

    assert_equal 0.3, result.material_weight
    assert_equal 4.5, result.mat_kg
    assert_equal 5.18, result.mat_total_kg
  end

  test 'calculate_area calculates resin quantity' do
    service = QuantityCalculatorService.new(area: 8, layers: 2)
    result = service.calculate_area

    assert_equal 25.6, result.resin
    assert_equal 29.44, result.resin_total
  end

  test 'calculate_area calculates catalyst in ml' do
    service = QuantityCalculatorService.new(area: 10, layers: 2, catalyst: 2)
    result = service.calculate_area

    assert_equal 736.0, result.catalyst_ml
  end

  test 'calculate_area calculates total weight' do
    service = QuantityCalculatorService.new(area: 5, layers: 2, material: '450', catalyst: 1)
    result = service.calculate_area

    assert_equal 23.76, result.total_weight
  end

  test 'calculate_area handles zero layers' do
    service = QuantityCalculatorService.new(area: 10, layers: 0)
    result = service.calculate_area

    assert_equal 0.0, result.mat
    assert_equal 0.0, result.mat_total
    assert_equal 0.0, result.resin
    assert_equal 0.0, result.resin_total
  end

  test 'calculate_area handles zero area' do
    service = QuantityCalculatorService.new(area: 0, layers: 2)
    result = service.calculate_area

    assert_equal 0.0, result.mat
    assert_equal 0.0, result.mat_kg
    assert_equal 0.0, result.resin
  end

  test 'calculate_area handles decimal area values' do
    service = QuantityCalculatorService.new(area: 7.5, layers: 2, material: '450')
    result = service.calculate_area

    assert_equal 15.79, result.mat
  end

  test 'calculate_dimensions uses default values when no parameters provided' do
    service = QuantityCalculatorService.new
    result = service.calculate_dimensions

    assert_equal 1.0, result.area
    assert_equal 1, result.catalyst
    assert_equal '', result.material
    assert_equal 0.95, result.material_width
    assert_equal 1.6, result.ratio
  end

  test 'calculate_dimensions calculates area from length and width with zero depth' do
    service = QuantityCalculatorService.new(length: 5, width: 3, layers: 1)
    result = service.calculate_dimensions

    assert_equal 15.0, result.area
  end

  test 'calculate_dimensions calculates mat quantities based on calculated area' do
    service = QuantityCalculatorService.new(length: 4, width: 2, layers: 2)
    result = service.calculate_dimensions

    assert_equal 16.84, result.mat
    assert_equal 19.37, result.mat_total
  end

  test 'calculate_dimensions calculates material weight with dimensions' do
    service = QuantityCalculatorService.new(length: 6, width: 4, layers: 2, material: '300')
    result = service.calculate_dimensions

    assert_equal 14.4, result.mat_kg
    assert_equal 16.56, result.mat_total_kg
  end

  test 'calculate_dimensions calculates resin based on calculated area' do
    service = QuantityCalculatorService.new(length: 5, width: 2, layers: 3)
    result = service.calculate_dimensions

    assert_equal 48.0, result.resin
    assert_equal 55.2, result.resin_total
  end

  test 'calculate_dimensions calculates catalyst from resin total' do
    service = QuantityCalculatorService.new(length: 3, width: 2, layers: 1, catalyst: 2)
    result = service.calculate_dimensions

    assert_equal 220.8, result.catalyst_ml
  end

  test 'calculate_dimensions calculates total weight with all components' do
    service = QuantityCalculatorService.new(length: 4, width: 3, layers: 1, material: '450', catalyst: 1)
    result = service.calculate_dimensions

    assert_equal 28.51, result.total_weight
  end

  test 'calculate_dimensions handles decimal length and width values' do
    service = QuantityCalculatorService.new(length: 4.5, width: 3.2, layers: 1)
    result = service.calculate_dimensions

    assert_equal 14.4, result.area
  end

  test 'calculate_mould_rectangle uses default values when no parameters provided' do
    service = QuantityCalculatorService.new
    result = service.calculate_mould_rectangle

    assert_equal 1, result.catalyst
    assert_equal '', result.material
    assert_equal 0.95, result.material_width
    assert_equal 1.6, result.ratio
  end

  test 'calculate_mould_rectangle calculates area including depth for rectangular mould' do
    service = QuantityCalculatorService.new(length: 5, width: 3, depth: 2, layers: 1)
    result = service.calculate_mould_rectangle

    assert_equal 47.0, result.area
  end

  test 'calculate_mould_rectangle calculates surface area of mould with all six faces' do
    service = QuantityCalculatorService.new(length: 4, width: 3, depth: 2, layers: 1)
    result = service.calculate_mould_rectangle

    assert_equal 40.0, result.area
  end

  test 'calculate_mould_rectangle calculates mat quantities based on mould area' do
    service = QuantityCalculatorService.new(length: 6, width: 4, depth: 3, layers: 2)
    result = service.calculate_mould_rectangle

    assert_equal 176.84, result.mat
    assert_equal 203.37, result.mat_total
  end

  test 'calculate_mould_rectangle calculates material weight for mould' do
    service = QuantityCalculatorService.new(length: 5, width: 4, depth: 2, layers: 1, material: '450')
    result = service.calculate_mould_rectangle

    assert_equal 25.2, result.mat_kg
    assert_equal 28.98, result.mat_total_kg
  end

  test 'calculate_mould_rectangle calculates resin for mould surface area' do
    service = QuantityCalculatorService.new(length: 3, width: 2, depth: 1, layers: 2)
    result = service.calculate_mould_rectangle

    assert_equal 51.2, result.resin
    assert_equal 58.88, result.resin_total
  end

  test 'calculate_mould_rectangle calculates catalyst based on resin total' do
    service = QuantityCalculatorService.new(length: 4, width: 3, depth: 2, layers: 1, catalyst: 2)
    result = service.calculate_mould_rectangle

    assert_equal 1472.0, result.catalyst_ml
  end

  test 'calculate_mould_rectangle calculates total weight including all components' do
    service = QuantityCalculatorService.new(length: 3, width: 2, depth: 1, layers: 1, material: '300', catalyst: 1)
    result = service.calculate_mould_rectangle

    assert_equal 35.25, result.total_weight
  end

  test 'calculate_mould_rectangle handles zero depth (flat surface)' do
    service = QuantityCalculatorService.new(length: 5, width: 3, depth: 0, layers: 1)
    result = service.calculate_mould_rectangle

    assert_equal 15.0, result.area
  end

  test 'calculate_mould_rectangle handles cube dimensions (all sides equal)' do
    service = QuantityCalculatorService.new(length: 4, width: 4, depth: 4, layers: 1)
    result = service.calculate_mould_rectangle

    assert_equal 80.0, result.area
  end

  test 'calculate_mould_rectangle handles decimal dimension values' do
    service = QuantityCalculatorService.new(length: 5.5, width: 3.5, depth: 2.5, layers: 1)
    result = service.calculate_mould_rectangle

    assert_equal 64.25, result.area
  end

  test 'calculate_mould_rectangle handles zero layers' do
    service = QuantityCalculatorService.new(length: 5, width: 3, depth: 2, layers: 0)
    result = service.calculate_mould_rectangle

    assert_equal 0.0, result.mat
    assert_equal 0.0, result.resin
  end

  test 'handles different material weights' do
    materials = %w[300 450 600 800]
    materials.each do |material|
      service = QuantityCalculatorService.new(area: 10, layers: 1, material: material)
      result = service.calculate_area

      expected_weight = material.to_i / 1000.0
      assert_equal expected_weight, result.material_weight
    end
  end

  test 'applies 15% wastage factor to mat and resin' do
    service = QuantityCalculatorService.new(area: 10, layers: 1)
    result = service.calculate_area

    mat_without_wastage = (10.0 * 1) / 0.95
    assert_equal (mat_without_wastage * 1.15).round(2), result.mat_total

    resin_without_wastage = (10.0 * 1) * 1.6
    assert_equal (resin_without_wastage * 1.15).round(2), result.resin_total
  end

  test 'handles large values' do
    service = QuantityCalculatorService.new(area: 100, layers: 5, material: '600', catalyst: 3)
    result = service.calculate_area

    assert result.mat.positive?
    assert result.resin_total.positive?
    assert result.total_weight.positive?
  end
end
