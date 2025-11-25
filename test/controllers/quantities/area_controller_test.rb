# frozen_string_literal: true

require 'test_helper'

class Quantities::AreaControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/quantities/area'
    assert_response :success
  end

  test 'should use default values when no parameters provided' do
    get '/quantities/area'
    assert_response :success
    assert_equal 1.0, assigns(:area)
    assert_equal 1, assigns(:catalyst)
    assert_equal '', assigns(:material)
    assert_equal 0.95, assigns(:material_width)
    assert_equal 1.6, assigns(:ratio)
    assert_equal 0, assigns(:layers)
  end

  test 'should calculate mat with given area and layers' do
    get '/quantities/area', params: { area: 10, layers: 2 }
    assert_response :success
    # mat = (area * layers) / material_width = (10 * 2) / 0.95 = 21.05
    assert_equal 21.05, assigns(:mat)
    # mat_total = mat * 1.15 = 21.05 * 1.15 = 24.21
    assert_equal 24.21, assigns(:mat_total)
  end

  test 'should calculate material weight in kg' do
    get '/quantities/area', params: { area: 5, layers: 3, material: '300' }
    assert_response :success
    # material_weight = 300 / 1000 = 0.3 kg/m²
    assert_equal 0.3, assigns(:material_weight)
    # mat_kg = (area * layers) * material_weight = (5 * 3) * 0.3 = 4.5
    assert_equal 4.5, assigns(:mat_kg)
    # mat_total_kg = mat_kg * 1.15 = 4.5 * 1.15 = 5.18
    assert_equal 5.18, assigns(:mat_total_kg)
  end

  test 'should calculate resin quantity' do
    get '/quantities/area', params: { area: 8, layers: 2 }
    assert_response :success
    # resin = (area * layers) * ratio = (8 * 2) * 1.6 = 25.6
    assert_equal 25.6, assigns(:resin)
    # resin_total = resin * 1.15 = 25.6 * 1.15 = 29.44
    assert_equal 29.44, assigns(:resin_total)
  end

  test 'should calculate catalyst in ml' do
    get '/quantities/area', params: { area: 10, layers: 2, catalyst: 2 }
    assert_response :success
    # resin_total = (10 * 2) * 1.6 * 1.15 = 36.8
    # catalyst_ml = ((resin_total / 10) * catalyst) * 100 = ((36.8 / 10) * 2) * 100 = 736
    assert_equal 736.0, assigns(:catalyst_ml)
  end

  test 'should calculate total weight' do
    get '/quantities/area', params: { area: 5, layers: 2, material: '450', catalyst: 1 }
    assert_response :success
    # mat_total_kg = (5 * 2) * 0.45 * 1.15 = 5.18
    # resin_total = (5 * 2) * 1.6 * 1.15 = 18.4
    # catalyst_ml = ((18.4 / 10) * 1) * 100 = 184.0
    # total_weight = 5.18 + 18.4 + (184.0 / 1000) = 23.76
    assert_equal 23.76, assigns(:total_weight)
  end

  test 'should handle zero layers' do
    get '/quantities/area', params: { area: 10, layers: 0 }
    assert_response :success
    assert_equal 0.0, assigns(:mat)
    assert_equal 0.0, assigns(:mat_total)
    assert_equal 0.0, assigns(:resin)
    assert_equal 0.0, assigns(:resin_total)
  end

  test 'should handle zero area' do
    get '/quantities/area', params: { area: 0, layers: 2 }
    assert_response :success
    assert_equal 0.0, assigns(:mat)
    assert_equal 0.0, assigns(:mat_kg)
    assert_equal 0.0, assigns(:resin)
  end

  test 'should round results to 2 decimal places' do
    get '/quantities/area', params: { area: 3.333, layers: 3 }
    assert_response :success
    # All calculations should be rounded to 2 decimal places
    assert_kind_of Float, assigns(:mat)
    assert_equal 2, assigns(:mat).to_s.split('.').last.length if assigns(:mat).to_s.include?('.')
  end

  test 'should apply 15% wastage factor to mat and resin' do
    get '/quantities/area', params: { area: 10, layers: 1 }
    assert_response :success
    # Verify wastage factor of 1.15 (15%)
    mat_without_wastage = (10.0 * 1) / 0.95
    assert_equal (mat_without_wastage * 1.15).round(2), assigns(:mat_total)

    resin_without_wastage = (10.0 * 1) * 1.6
    assert_equal (resin_without_wastage * 1.15).round(2), assigns(:resin_total)
  end

  test 'should use material width of 0.95m' do
    get '/quantities/area'
    assert_response :success
    assert_equal 0.95, assigns(:material_width)
  end

  test 'should use resin to glass ratio of 1.6' do
    get '/quantities/area'
    assert_response :success
    assert_equal 1.6, assigns(:ratio)
  end

  test 'should handle different material weights' do
    materials = %w[300 450 600 800]
    materials.each do |material|
      get '/quantities/area', params: { area: 10, layers: 1, material: material }
      assert_response :success
      expected_weight = material.to_i / 1000.0
      assert_equal expected_weight, assigns(:material_weight)
    end
  end

  test 'should handle empty material parameter' do
    get '/quantities/area', params: { area: 10, layers: 1, material: '' }
    assert_response :success
    assert_equal 0.0, assigns(:material_weight)
    assert_equal 0.0, assigns(:mat_kg)
  end

  test 'should calculate with large values' do
    get '/quantities/area', params: { area: 100, layers: 5, material: '600', catalyst: 3 }
    assert_response :success
    assert assigns(:mat).positive?
    assert assigns(:resin_total).positive?
    assert assigns(:total_weight).positive?
  end

  test 'should handle decimal area values' do
    get '/quantities/area', params: { area: 7.5, layers: 2, material: '450' }
    assert_response :success
    # mat = (7.5 * 2) / 0.95 = 15.79
    assert_equal 15.79, assigns(:mat)
  end
end
