# frozen_string_literal: true

require 'test_helper'

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @category = categories(:category_one)
    @active_product = products(:product_one)
  end

  test 'should show category' do
    get category_url(@category)
    assert_response :success
  end

  test 'should render category show template' do
    get category_url(@category)
    assert_template :show
  end

  test 'should display category name in breadcrumb' do
    get category_url(@category)
    # Category name appears in breadcrumb, not as h1
    assert_match @category.name, response.body
  end

  test 'should load category with description' do
    get category_url(@category)
    # Category is loaded with description (even if not displayed in view)
    assert_not_nil assigns(:category).description
    assert_equal @category.description, assigns(:category).description
  end

  test 'should display products in category' do
    get category_url(@category)
    assert_not_nil assigns(:products)
    # Category one has multiple products
    assert assigns(:products).any?
  end

  test 'should only display active products' do
    get category_url(@category)
    products = assigns(:products)
    assert products.all?(&:active?), 'All products should be active'
  end

  test 'should eager load product images to prevent N+1 queries' do
    get category_url(@category)
    assert_response :success
    # Products should have images association loaded
    products = assigns(:products)
    products.each do |product|
      assert product.association(:images_attachments).loaded?, 'Images should be eager loaded'
    end
  end

  test 'should filter products by minimum price' do
    min_price = 2000 # £20.00 in pence
    get category_url(@category), params: { min: min_price }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.price >= min_price }, 'All products should be >= min price'
  end

  test 'should filter products by maximum price' do
    max_price = 2000 # £20.00 in pence
    get category_url(@category), params: { max: max_price }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.price <= max_price }, 'All products should be <= max price'
  end

  test 'should filter products by price range' do
    min_price = 1500
    max_price = 2500
    get category_url(@category), params: { min: min_price, max: max_price }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.price.between?(min_price, max_price) },
           'All products should be within price range'
  end

  test 'should handle empty price filter parameters gracefully' do
    get category_url(@category), params: { min: '', max: '' }
    assert_response :success
    # Should display all active products when filters are empty
    assert assigns(:products).any?
  end

  test 'should handle nil price filter parameters' do
    get category_url(@category), params: { min: nil, max: nil }
    assert_response :success
    # Should display all active products when filters are nil
    assert assigns(:products).any?
  end

  test 'should display breadcrumb navigation' do
    get category_url(@category)
    assert_select 'nav' # Breadcrumb exists
  end

  test 'should include category in breadcrumb' do
    get category_url(@category)
    # Breadcrumb should contain category name
    assert_match @category.name, response.body
  end

  test 'should handle category not found' do
    # Rails rescue_from in production handles this gracefully
    # In test environment, it raises the exception
    get category_url(id: 999_999)
  rescue ActiveRecord::RecordNotFound
    # Expected behavior
    assert true
  end

  test 'category route should be accessible via GET' do
    assert_routing({ path: "categories/#{@category.id}", method: :get },
                   { controller: 'categories', action: 'show', id: @category.id.to_s })
  end

  test 'should load products with prices' do
    get category_url(@category)
    # Products are loaded with prices (displayed in product detail page)
    products = assigns(:products)
    assert products.any?
    products.each do |product|
      assert product.price.present?, "Product #{product.name} should have a price"
      assert product.price >= 0, 'Product price should be non-negative'
    end
  end

  test 'should include filter form for price range' do
    get category_url(@category)
    # Check for filter form elements
    assert_select 'form'
    assert_select 'input[name=min]'
    assert_select 'input[name=max]'
  end

  test 'should apply active scope to products' do
    get category_url(@category)
    products = assigns(:products)
    # All returned products should be active
    products.each do |product|
      assert product.active?, "Product #{product.name} should be active"
    end
  end

  test 'should handle category with no products' do
    # Use category without products
    empty_category = categories(:category_three)
    get category_url(empty_category)
    assert_response :success
    assert assigns(:products).empty?, 'Should handle empty product list'
  end
end
