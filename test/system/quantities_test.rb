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
end
