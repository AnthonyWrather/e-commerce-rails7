# frozen_string_literal: true

require 'application_system_test_case'

class QuantitiesTest < ApplicationSystemTestCase
  test 'visiting the quantities index page' do
    visit quantities_url

    assert_selector 'h1', text: 'Under Construction'
    assert_link 'Calculate by Area'
    assert_link 'Calculate by Dimensions'
    assert_link 'Calculate a Rectangle Mould'
  end

  test 'quantities index displays breadcrumbs' do
    visit quantities_url

    assert_link 'Home'
    assert_text 'Quantity Calculator'
  end

  test 'can navigate to area calculator' do
    visit quantities_url

    click_on 'Calculate by Area'

    assert_current_path quantities_area_path
    assert_selector 'h2', text: 'Calculate Required Material'
  end

  test 'area calculator displays form' do
    visit quantities_area_url

    assert_selector 'input[name="area"]'
    assert_selector 'select[name="layers"]'
    assert_selector 'select[name="material"]'
    assert_selector 'select[name="catalyst"]'
    assert_button 'Calculate'
  end

  test 'area calculator performs calculation' do
    visit quantities_area_url

    fill_in 'area', with: '10'
    select '2', from: 'layers'
    select '300g Chop Strand Mat', from: 'material'
    select '2', from: 'catalyst'

    click_button 'Calculate'

    # Results should be displayed
    assert_text 'Results'
    assert_text 'Min Mat Req'
  end

  test 'area calculator validates calculation accuracy' do
    visit quantities_area_url

    # Test with known values: 10m² area, 2 layers, 300g material, 2% catalyst
    fill_in 'area', with: '10'
    select '2', from: 'layers'
    select '300g Chop Strand Mat', from: 'material'
    select '2', from: 'catalyst'

    click_button 'Calculate'

    # Expected calculations:
    # mat = (10 * 2) / 0.95 = 21.05 m
    # mat_total = 21.05 * 1.15 = 24.21 m
    assert_text '21.05 m'
    assert_text '24.21 m'

    # mat_kg = (10 * 2) * 0.3 = 6.0 kg
    # mat_total_kg = 6.0 * 1.15 = 6.9 kg
    assert_text '6.0 kg'
    assert_text '6.9 kg'

    # resin = (10 * 2) * 1.6 = 32.0 kg
    # resin_total = 32.0 * 1.15 = 36.8 kg
    assert_text '32.0 kg'
    assert_text '36.8 kg'

    # catalyst = ((36.8 / 10) * 2) * 100 = 736.0 ml
    assert_text '736.0 ml'

    # total_weight = 6.9 + 36.8 + 0.736 = 44.44 kg
    assert_text '44.44 kg'
  end

  test 'area calculator handles edge case with 1 layer' do
    visit quantities_area_url

    fill_in 'area', with: '5'
    select '1', from: 'layers'
    select '600g Chop Strand Mat', from: 'material'
    select '1', from: 'catalyst'

    click_button 'Calculate'

    # mat = (5 * 1) / 0.95 = 5.26 m
    assert_text '5.26 m'

    # mat_kg = (5 * 1) * 0.6 = 3.0 kg
    assert_text '3.0 kg'

    # Verify results table is displayed
    assert_text 'Results'
    assert_text 'Total Material Weight'
  end

  test 'can navigate to dimensions calculator' do
    visit quantities_url

    click_on 'Calculate by Dimensions'

    assert_current_path quantities_dimensions_path
    # Page doesn't have h1, just verify we're on the right page
    assert_selector 'form[action="/quantities/dimensions"]'
  end

  test 'dimensions calculator displays form' do
    visit quantities_dimensions_url

    assert_selector 'input[name="length"]'
    assert_selector 'input[name="width"]'
    assert_selector 'select[name="layers"]'
    assert_button 'Calculate'
  end

  test 'can navigate to mould rectangle calculator' do
    visit quantities_url

    click_on 'Calculate a Rectangle Mould'

    assert_current_path quantities_mould_rectangle_path
    # Page doesn't have h1, just verify form exists
    assert_selector 'form[action="/quantities/mould_rectangle"]'
  end

  test 'mould rectangle calculator displays form' do
    visit quantities_mould_rectangle_url

    assert_selector 'input[name="length"]'
    assert_selector 'input[name="width"]'
    assert_selector 'input[name="depth"]'
    assert_selector 'select[name="layers"]'
    assert_button 'Calculate'
  end

  test 'dimensions calculator validates calculation accuracy' do
    visit quantities_dimensions_url

    # Test with length=2, width=3, depth=0 (flat rectangle), 1 layer, 450g material
    fill_in 'length', with: '2'
    fill_in 'width', with: '3'
    select '1', from: 'layers'
    select '450g Chop Strand Mat', from: 'material'
    select '1', from: 'catalyst'

    click_button 'Calculate'

    # area = (2 * 3) + (2 * 2 * 0) + (2 * 3 * 0) = 6.0 m²
    assert_text '6.0 m²'

    # mat = (6.0 * 1) / 0.95 = 6.32 m
    assert_text '6.32 m'

    # Verify results displayed
    assert_text 'Results'
    assert_text 'Min Mat Req'
  end

  test 'mould rectangle calculator validates calculation with depth' do
    visit quantities_mould_rectangle_url

    # Test with cube: length=1, width=1, depth=1, 2 layers
    fill_in 'length', with: '1'
    fill_in 'width', with: '1'
    fill_in 'depth', with: '1'
    select '2', from: 'layers'
    select '600g Woven Roving', from: 'material'
    select '2', from: 'catalyst'

    click_button 'Calculate'

    # area = (1 * 1) + (2 * 1 * 1) + (2 * 1 * 1) = 5.0 m²
    assert_text '5.0 m²'

    # mat = (5.0 * 2) / 0.95 = 10.53 m
    assert_text '10.53 m'

    # mat_kg = (5.0 * 2) * 0.6 = 6.0 kg
    assert_text '6.0 kg'

    # Verify calculation completed
    assert_text 'Results'
    assert_text 'Total Material Weight'
  end

  test 'quantities calculators display consistent parameters table' do
    visit quantities_area_url

    fill_in 'area', with: '5'
    select '1', from: 'layers'
    select '300g Chop Strand Mat', from: 'material'
    select '1', from: 'catalyst'

    click_button 'Calculate'

    # Check parameters are displayed
    assert_text 'Parameters'
    assert_text 'Material Width'
    assert_text '0.95 m'
    assert_text 'Resin To Glass Ratio'
    assert_text '1.6:1'
  end
end
