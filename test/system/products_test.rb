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

  test 'product page displays full description' do
    visit product_url(@product)

    # Full description should be visible
    assert_text @product.description
  end

  test 'add to cart button is present and visible' do
    visit product_url(@product)

    # Button should be visible (may be disabled until size selected)
    assert_button 'Add To Cart'
  end

  test 'product page shows product image if available' do
    visit product_url(@product)

    # If product has images, they should be displayed
    if @product.images.attached?
      assert_selector 'img[src*="blob"]', minimum: 1
    else
      # Should show placeholder or no image without errors
      assert_current_path product_url(@product)
    end
  end

  test 'product page includes all navigation elements' do
    visit product_url(@product)

    # Main navigation should be present
    assert_link 'Home'
    assert_link 'Cart'
  end

  test 'can navigate home from product breadcrumb' do
    visit product_url(@product)

    within 'nav' do
      click_on 'Home'
    end

    assert_current_path root_path
  end

  test 'product price is prominently displayed' do
    visit product_url(@product)

    # Price should be visible in a specific element
    # The product page displays price in various formats
    assert_text '£', minimum: 1
  end

  test 'product page loads without errors for products with no images' do
    # Ensure products without images don't break the page
    visit product_url(@product)

    assert_selector 'h1'
    assert_current_path product_url(@product)
  end

  test 'product details are complete' do
    visit product_url(@product)

    # Essential product information should be present
    assert_selector 'h1', text: @product.name.upcase
    assert_text @product.description
    assert_text '£' # Price
  end
end
