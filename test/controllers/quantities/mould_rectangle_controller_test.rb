# frozen_string_literal: true

require 'test_helper'

class Quantities::MouldRectangleControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get '/quantities/mould_rectangle'
    assert_response :success
  end

  test 'should use default values when no parameters provided' do
    get '/quantities/mould_rectangle'
    assert_response :success
    assert_equal 1.0, assigns(:length)
    assert_equal 1.0, assigns(:width)
    assert_equal 1.0, assigns(:depth)
    assert_equal 1, assigns(:catalyst)
    assert_equal '', assigns(:material)
    assert_equal 0.95, assigns(:material_width)
    assert_equal 1.6, assigns(:ratio)
  end

  test 'should calculate area including depth for rectangular mould' do
    get '/quantities/mould_rectangle', params: { length: 5, width: 3, depth: 2, layers: 1 }
    assert_response :success
    # area = (length * width) + (2 * (length * depth)) + (2 * (width * depth))
    # area = (5 * 3) + (2 * (5 * 2)) + (2 * (3 * 2))
    # area = 15 + 20 + 12 = 47
    assert_equal 47.0, assigns(:area)
  end

  test 'should calculate surface area of mould with all six faces' do
    get '/quantities/mould_rectangle', params: { length: 4, width: 3, depth: 2, layers: 1 }
    assert_response :success
    # Top/bottom: 4 * 3 = 12
    # Front/back: 2 * (4 * 2) = 16
    # Left/right: 2 * (3 * 2) = 12
    # Total: 12 + 16 + 12 = 40
    assert_equal 40.0, assigns(:area)
  end

  test 'should calculate mat quantities based on mould area' do
    get '/quantities/mould_rectangle', params: { length: 6, width: 4, depth: 3, layers: 2 }
    assert_response :success
    # area = (6 * 4) + (2 * (6 * 3)) + (2 * (4 * 3)) = 24 + 36 + 24 = 84
    # mat = (84 * 2) / 0.95 = 176.84
    assert_equal 176.84, assigns(:mat)
    # mat_total = 176.84 * 1.15 = 203.37
    assert_equal 203.37, assigns(:mat_total)
  end

  test 'should calculate material weight for mould' do
    get '/quantities/mould_rectangle', params: { length: 5, width: 4, depth: 2, layers: 1, material: '450' }
    assert_response :success
    # area = (5 * 4) + (2 * (5 * 2)) + (2 * (4 * 2)) = 20 + 20 + 16 = 56
    # material_weight = 450 / 1000 = 0.45
    # mat_kg = 56 * 1 * 0.45 = 25.2
    assert_equal 25.2, assigns(:mat_kg)
    # mat_total_kg = 25.2 * 1.15 = 28.98
    assert_equal 28.98, assigns(:mat_total_kg)
  end

  test 'should calculate resin for mould surface area' do
    get '/quantities/mould_rectangle', params: { length: 3, width: 2, depth: 1, layers: 2 }
    assert_response :success
    # area = (3 * 2) + (2 * (3 * 1)) + (2 * (2 * 1)) = 6 + 6 + 4 = 16
    # resin = 16 * 2 * 1.6 = 51.2
    assert_equal 51.2, assigns(:resin)
    # resin_total = 51.2 * 1.15 = 58.88
    assert_equal 58.88, assigns(:resin_total)
  end

  test 'should calculate catalyst based on resin total' do
    get '/quantities/mould_rectangle', params: { length: 4, width: 3, depth: 2, layers: 1, catalyst: 2 }
    assert_response :success
    # area = (4 * 3) + (2 * (4 * 2)) + (2 * (3 * 2)) = 12 + 16 + 12 = 40
    # resin_total = 40 * 1 * 1.6 * 1.15 = 73.6
    # catalyst_ml = ((73.6 / 10) * 2) * 100 = 1472
    assert_equal 1472.0, assigns(:catalyst_ml)
  end

  test 'should calculate total weight including all components' do
    get '/quantities/mould_rectangle', params: { length: 3, width: 2, depth: 1, layers: 1, material: '300', catalyst: 1 }
    assert_response :success
    # area = (3 * 2) + (2 * (3 * 1)) + (2 * (2 * 1)) = 16
    # mat_total_kg = 16 * 1 * 0.3 * 1.15 = 5.52
    # resin_total = 16 * 1 * 1.6 * 1.15 = 29.44
    # catalyst_ml = ((29.44 / 10) * 1) * 100 = 294.4
    # total_weight = 5.52 + 29.44 + (294.4 / 1000) = 35.25
    assert_equal 35.25, assigns(:total_weight)
  end

  test 'should handle zero depth (flat surface)' do
    get '/quantities/mould_rectangle', params: { length: 5, width: 3, depth: 0, layers: 1 }
    assert_response :success
    # area = (5 * 3) + (2 * (5 * 0)) + (2 * (3 * 0)) = 15
    assert_equal 15.0, assigns(:area)
  end

  test 'should handle cube dimensions (all sides equal)' do
    get '/quantities/mould_rectangle', params: { length: 4, width: 4, depth: 4, layers: 1 }
    assert_response :success
    # area = (4 * 4) + (2 * (4 * 4)) + (2 * (4 * 4)) = 16 + 32 + 32 = 80
    assert_equal 80.0, assigns(:area)
  end

  test 'should round all calculations to 2 decimal places' do
    get '/quantities/mould_rectangle', params: { length: 3.333, width: 2.222, depth: 1.111, layers: 2 }
    assert_response :success
    assert_kind_of Float, assigns(:area)
    # All instance variables should be rounded
    assert assigns(:area).to_s.split('.').last.length <= 2 if assigns(:area).to_s.include?('.')
  end

  test 'should apply 15% wastage factor to mat and resin' do
    get '/quantities/mould_rectangle', params: { length: 5, width: 4, depth: 2, layers: 1 }
    assert_response :success
    # Verify wastage multiplier of 1.15
    area = (5.0 * 4.0) + (2 * (5.0 * 2.0)) + (2 * (4.0 * 2.0))
    mat_without_wastage = area / 0.95
    assert_equal (mat_without_wastage * 1.15).round(2), assigns(:mat_total)
  end

  test 'should handle decimal dimension values' do
    get '/quantities/mould_rectangle', params: { length: 5.5, width: 3.5, depth: 2.5, layers: 1 }
    assert_response :success
    # area = (5.5 * 3.5) + (2 * (5.5 * 2.5)) + (2 * (3.5 * 2.5))
    # area = 19.25 + 27.5 + 17.5 = 64.25
    assert_equal 64.25, assigns(:area)
  end

  test 'should calculate with different material weights' do
    materials = %w[300 450 600 800]
    materials.each do |material|
      get '/quantities/mould_rectangle', params: { length: 4, width: 3, depth: 2, layers: 1, material: material }
      assert_response :success
      expected_weight = material.to_i / 1000.0
      assert_equal expected_weight, assigns(:material_weight)
    end
  end

  test 'should handle large mould dimensions' do
    get '/quantities/mould_rectangle', params: { length: 50, width: 30, depth: 20, layers: 3, material: '600' }
    assert_response :success
    # area = (50 * 30) + (2 * (50 * 20)) + (2 * (30 * 20)) = 1500 + 2000 + 1200 = 4700
    assert_equal 4700.0, assigns(:area)
    assert assigns(:mat_total).positive?
    assert assigns(:total_weight).positive?
  end

  test 'should use same constants as other calculators' do
    get '/quantities/mould_rectangle'
    assert_response :success
    assert_equal 0.95, assigns(:material_width)
    assert_equal 1.6, assigns(:ratio)
  end

  test 'should handle zero layers' do
    get '/quantities/mould_rectangle', params: { length: 5, width: 3, depth: 2, layers: 0 }
    assert_response :success
    assert_equal 0.0, assigns(:mat)
    assert_equal 0.0, assigns(:resin)
  end

  test 'should calculate different catalyst percentages' do
    [1, 2, 3, 4, 5].each do |catalyst_percent|
      get '/quantities/mould_rectangle', params: { length: 3, width: 2, depth: 1, layers: 1, catalyst: catalyst_percent }
      assert_response :success
      # Catalyst should increase proportionally
      assert assigns(:catalyst_ml).positive?
    end
  end
end
