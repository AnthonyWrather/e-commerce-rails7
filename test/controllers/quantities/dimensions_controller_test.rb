# frozen_string_literal: true

require 'test_helper'

class Quantities::DimensionsControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/quantities/dimensions'
    assert_response :success
  end

  test 'should use default values when no parameters provided' do
    get '/quantities/dimensions'
    assert_response :success
    assert_equal 1.0, assigns(:length)
    assert_equal 1.0, assigns(:width)
    assert_equal 0, assigns(:depth)
    assert_equal 1, assigns(:catalyst)
    assert_equal '', assigns(:material)
    assert_equal 0.95, assigns(:material_width)
    assert_equal 1.6, assigns(:ratio)
  end

  test 'should calculate area from length and width with zero depth' do
    get '/quantities/dimensions', params: { length: 5, width: 3, layers: 1 }
    assert_response :success
    # area = (length * width) + (2 * (length * depth)) + (2 * (width * depth))
    # depth is always 0, so area = length * width = 5 * 3 = 15
    assert_equal 15.0, assigns(:area)
  end

  test 'should calculate mat quantities based on calculated area' do
    get '/quantities/dimensions', params: { length: 4, width: 2, layers: 2 }
    assert_response :success
    # area = 4 * 2 = 8
    # mat = (8 * 2) / 0.95 = 16.84
    assert_equal 16.84, assigns(:mat)
    # mat_total = 16.84 * 1.15 = 19.37
    assert_equal 19.37, assigns(:mat_total)
  end

  test 'should calculate material weight with dimensions' do
    get '/quantities/dimensions', params: { length: 6, width: 4, layers: 2, material: '300' }
    assert_response :success
    # area = 6 * 4 = 24
    # material_weight = 300 / 1000 = 0.3
    # mat_kg = 24 * 2 * 0.3 = 14.4
    assert_equal 14.4, assigns(:mat_kg)
    # mat_total_kg = 14.4 * 1.15 = 16.56
    assert_equal 16.56, assigns(:mat_total_kg)
  end

  test 'should calculate resin based on calculated area' do
    get '/quantities/dimensions', params: { length: 5, width: 2, layers: 3 }
    assert_response :success
    # area = 5 * 2 = 10
    # resin = 10 * 3 * 1.6 = 48
    assert_equal 48.0, assigns(:resin)
    # resin_total = 48 * 1.15 = 55.2
    assert_equal 55.2, assigns(:resin_total)
  end

  test 'should calculate catalyst from resin total' do
    get '/quantities/dimensions', params: { length: 3, width: 2, layers: 1, catalyst: 2 }
    assert_response :success
    # area = 3 * 2 = 6
    # resin_total = 6 * 1 * 1.6 * 1.15 = 11.04
    # catalyst_ml = ((11.04 / 10) * 2) * 100 = 220.8
    assert_equal 220.8, assigns(:catalyst_ml)
  end

  test 'should calculate total weight with all components' do
    get '/quantities/dimensions', params: { length: 4, width: 3, layers: 1, material: '450', catalyst: 1 }
    assert_response :success
    # area = 4 * 3 = 12
    # mat_total_kg = 12 * 1 * 0.45 * 1.15 = 6.21
    # resin_total = 12 * 1 * 1.6 * 1.15 = 22.08
    # catalyst_ml = ((22.08 / 10) * 1) * 100 = 220.8
    # total_weight = 6.21 + 22.08 + (220.8 / 1000) = 28.51
    assert_equal 28.51, assigns(:total_weight)
  end

  test 'should handle zero dimensions' do
    get '/quantities/dimensions', params: { length: 0, width: 5, layers: 2 }
    assert_response :success
    assert_equal 0.0, assigns(:area)
    assert_equal 0.0, assigns(:mat)
  end

  test 'should always set depth to zero' do
    # Depth is hardcoded to 0 in dimensions controller
    get '/quantities/dimensions', params: { length: 5, width: 3, depth: 10 }
    assert_response :success
    assert_equal 0, assigns(:depth)
    # Area should not include depth calculations
    assert_equal 15.0, assigns(:area) # length * width only
  end

  test 'should round all results to 2 decimal places' do
    get '/quantities/dimensions', params: { length: 3.333, width: 2.222, layers: 2 }
    assert_response :success
    assert_kind_of Float, assigns(:area)
    # Verify rounding
    assert assigns(:area).to_s.split('.').last.length <= 2 if assigns(:area).to_s.include?('.')
  end

  test 'should apply 15% wastage factor' do
    get '/quantities/dimensions', params: { length: 10, width: 5, layers: 1 }
    assert_response :success
    # Verify wastage factor (controller rounds before applying wastage)
    area = 50.0
    mat_without_wastage = (area / 0.95).round(2)
    assert_equal (mat_without_wastage * 1.15).round(2), assigns(:mat_total)
  end

  test 'should handle decimal length and width values' do
    get '/quantities/dimensions', params: { length: 4.5, width: 3.2, layers: 1 }
    assert_response :success
    # area = 4.5 * 3.2 = 14.4
    assert_equal 14.4, assigns(:area)
  end

  test 'should calculate with different material types' do
    materials = %w[300 450 600 800]
    materials.each do |material|
      get '/quantities/dimensions', params: { length: 5, width: 4, layers: 1, material: material }
      assert_response :success
      expected_weight = material.to_i / 1000.0
      assert_equal expected_weight, assigns(:material_weight)
    end
  end

  test 'should handle large dimension values' do
    get '/quantities/dimensions', params: { length: 100, width: 50, layers: 5, material: '600' }
    assert_response :success
    # area = 100 * 50 = 5000
    assert_equal 5000.0, assigns(:area)
    assert assigns(:mat_total).positive?
    assert assigns(:total_weight).positive?
  end

  test 'should use same constants as area controller' do
    get '/quantities/dimensions'
    assert_response :success
    assert_equal 0.95, assigns(:material_width)
    assert_equal 1.6, assigns(:ratio)
  end
end
