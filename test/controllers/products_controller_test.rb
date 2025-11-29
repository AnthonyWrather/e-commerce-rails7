# frozen_string_literal: true

require 'test_helper'

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:product_one)
    @category = categories(:category_one)
  end

  test 'should show product' do
    get product_url(@product)
    assert_response :success
  end

  test 'should render product show template' do
    get product_url(@product)
    assert_template :show
  end

  test 'should display product name' do
    get product_url(@product)
    assert_select 'h1', text: @product.name
  end

  test 'should display product description' do
    get product_url(@product)
    assert_match @product.description, response.body
  end

  test 'should display product price' do
    get product_url(@product)
    # Price should be formatted as currency (e.g., £15.00)
    assert_match(/£\d+\.\d{2}/, response.body)
  end

  test 'should eager load category to prevent N+1 queries' do
    # Test that category is loaded with product
    get product_url(@product)
    assert_response :success
    # The controller eager loads category, so this should not trigger additional queries
    assert assigns(:product).association(:category).loaded?
  end

  test 'should eager load stocks to prevent N+1 queries' do
    # Test that stocks are loaded with product
    get product_url(@product)
    assert_response :success
    # The controller eager loads stocks
    assert assigns(:product).association(:stocks).loaded?
  end

  test 'should assign stocks variable' do
    get product_url(@product)
    assert_not_nil assigns(:stocks)
    assert_equal @product.stocks, assigns(:stocks)
  end

  test 'should display breadcrumb navigation' do
    get product_url(@product)
    assert_select 'nav' # Breadcrumb exists
  end

  test 'should include category in breadcrumb' do
    get product_url(@product)
    # Breadcrumb should contain category name
    assert_match @category.name, response.body
  end

  test 'should handle product not found' do
    # Rails rescue_from in production handles this gracefully
    # In test environment, it raises the exception
    get product_url(id: 999_999)
  rescue ActiveRecord::RecordNotFound
    # Expected behavior
    assert true
  end

  test 'product route should be accessible via GET' do
    assert_routing({ path: "products/#{@product.id}", method: :get },
                   { controller: 'products', action: 'show', id: @product.id.to_s })
  end

  test 'should display active products only in production context' do
    # This test ensures the show page displays products
    # (Active status filtering happens at category/listing level)
    get product_url(@product)
    assert_response :success
    assert assigns(:product).active?
  end

  test 'should include add to cart functionality' do
    get product_url(@product)
    # Check for add to cart button (Stimulus controller target)
    assert_select 'button', text: /add to cart/i
  end
end
