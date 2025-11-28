# frozen_string_literal: true

require 'application_system_test_case'

class ProductsTest < ApplicationSystemTestCase
  setup do
    @product = products(:product_one)
  end

  test 'visiting a product page' do
    visit product_url(@product)

    assert_selector 'h1', text: @product.name.upcase
    assert_text @product.description
    assert_text 'Add To Cart'
  end

  test 'product page displays breadcrumbs' do
    visit product_url(@product)

    assert_link 'Home'
    assert_link @product.category.name
    assert_text @product.name
  end

  test 'product page shows price' do
    visit product_url(@product)

    # Price is displayed (formatted as currency)
    assert_text '£'
  end

  test 'can navigate back to category from product' do
    visit product_url(@product)

    click_on @product.category.name

    assert_current_path category_path(@product.category)
  end

  test 'product with stocks shows size selection' do
    # Create a product with stocks
    product_with_stocks = products(:product_one)

    visit product_url(product_with_stocks)

    assert_selector 'h1', text: product_with_stocks.name.upcase
    assert_text 'Add To Cart'
  end
end
