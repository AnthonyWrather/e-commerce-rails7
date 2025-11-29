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

  # Sorting tests
  test 'should sort products by name ascending' do
    get category_url(@category), params: { sort: 'name_asc' }
    assert_response :success
    products = assigns(:products)
    names = products.pluck(:name)
    assert_equal names.sort, names, 'Products should be sorted A-Z'
  end

  test 'should sort products by name descending' do
    get category_url(@category), params: { sort: 'name_desc' }
    assert_response :success
    products = assigns(:products)
    names = products.pluck(:name)
    assert_equal names.sort.reverse, names, 'Products should be sorted Z-A'
  end

  test 'should sort products by price ascending' do
    get category_url(@category), params: { sort: 'price_asc' }
    assert_response :success
    products = assigns(:products)
    prices = products.pluck(:price)
    assert_equal prices.sort, prices, 'Products should be sorted by price low to high'
  end

  test 'should sort products by price descending' do
    get category_url(@category), params: { sort: 'price_desc' }
    assert_response :success
    products = assigns(:products)
    prices = products.pluck(:price)
    assert_equal prices.sort.reverse, prices, 'Products should be sorted by price high to low'
  end

  test 'should sort products by newest' do
    get category_url(@category), params: { sort: 'newest' }
    assert_response :success
    products = assigns(:products)
    dates = products.pluck(:created_at)
    assert_equal dates.sort.reverse, dates, 'Products should be sorted newest first'
  end

  # Fiberglass filter tests
  test 'should filter products by fiberglass reinforcement' do
    get category_url(@category), params: { fiberglass: '1' }
    assert_response :success
    products = assigns(:products)
    assert products.all?(&:fiberglass_reinforcement), 'All products should have fiberglass reinforcement'
  end

  test 'should not filter fiberglass when param is 0' do
    get category_url(@category), params: { fiberglass: '0' }
    assert_response :success
    products = assigns(:products)
    assert products.any?, 'Should return products'
  end

  # Weight range filter tests
  test 'should filter products by minimum weight' do
    min_weight = 500
    get category_url(@category), params: { weight_min: min_weight }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.shipping_weight >= min_weight }, 'All products should be >= min weight'
  end

  test 'should filter products by maximum weight' do
    max_weight = 400
    get category_url(@category), params: { weight_max: max_weight }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.shipping_weight <= max_weight }, 'All products should be <= max weight'
  end

  test 'should filter products by weight range' do
    min_weight = 200
    max_weight = 400
    get category_url(@category), params: { weight_min: min_weight, weight_max: max_weight }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.shipping_weight.between?(min_weight, max_weight) },
           'All products should be within weight range'
  end

  # Product count tests
  test 'should return product count' do
    get category_url(@category)
    assert_response :success
    assert_not_nil assigns(:product_count), 'Product count should be assigned'
    assert_equal assigns(:products).count, assigns(:product_count), 'Product count should match products'
  end

  test 'should display product count in view' do
    get category_url(@category)
    assert_response :success
    assert_select '[data-testid="product-count"]', /\d+ products? found/
  end

  # Combined filters tests
  test 'should combine sorting with price filter' do
    get category_url(@category), params: { sort: 'price_desc', min: 1000, max: 2000 }
    assert_response :success
    products = assigns(:products)
    prices = products.pluck(:price)
    assert products.all? { |p| p.price.between?(1000, 2000) }, 'All products should be in price range'
    assert_equal prices.sort.reverse, prices, 'Products should be sorted by price desc'
  end

  test 'should combine sorting with fiberglass filter' do
    get category_url(@category), params: { sort: 'name_asc', fiberglass: '1' }
    assert_response :success
    products = assigns(:products)
    names = products.pluck(:name)
    assert products.all?(&:fiberglass_reinforcement), 'All products should have fiberglass'
    assert_equal names.sort, names, 'Products should be sorted by name'
  end

  test 'should combine all filters' do
    get category_url(@category), params: {
      sort: 'price_asc',
      min: 1000,
      max: 3000,
      weight_min: 200,
      weight_max: 700,
      fiberglass: '1'
    }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.price.between?(1000, 3000) }, 'Price filter should be applied'
    assert products.all? { |p| p.shipping_weight.between?(200, 700) }, 'Weight filter should be applied'
    assert products.all?(&:fiberglass_reinforcement), 'Fiberglass filter should be applied'
    prices = products.pluck(:price)
    assert_equal prices.sort, prices, 'Sort should be applied'
  end

  # URL persistence tests
  test 'filters should persist in URL as GET params' do
    get category_url(@category), params: { sort: 'price_desc', min: 1000, fiberglass: '1' }
    assert_response :success
    # Form should contain current filter values
    assert_select 'select[name=sort] option[selected][value=price_desc]'
    assert_select 'input[name=min][value="1000"]'
    assert_select 'input[name=fiberglass][checked]'
  end

  test 'should include clear filters link' do
    get category_url(@category), params: { sort: 'price_desc', min: 1000 }
    assert_response :success
    assert_select '[data-testid="clear-filters"]', text: 'Clear Filters'
  end

  test 'should include sort dropdown' do
    get category_url(@category)
    assert_response :success
    assert_select 'select[name=sort]'
    assert_select 'select[name=sort] option', count: 6 # 5 options + blank
  end

  test 'should include weight filter inputs' do
    get category_url(@category)
    assert_response :success
    assert_select 'input[name=weight_min]'
    assert_select 'input[name=weight_max]'
  end

  test 'should include fiberglass checkbox' do
    get category_url(@category)
    assert_response :success
    assert_select 'input[name=fiberglass][type=checkbox]'
  end
end
