# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product_one = products(:product_one)
    @product_two = products(:product_two)
    @product_three = products(:product_three)
    @category_one = categories(:category_one)
    @category_two = categories(:category_two)
  end

  test 'should get search index page' do
    get search_url
    assert_response :success
  end

  test 'should render search index template' do
    get search_url
    assert_template :index
  end

  test 'should display search form in results page' do
    get search_url
    assert_select 'form'
    assert_select 'input[name="q"]'
  end

  test 'should display empty state when no query provided' do
    get search_url
    assert_response :success
    assert_match 'Start Your Search', response.body
  end

  test 'should search products by name' do
    get search_url, params: { q: 'Chopped Strand' }
    assert_response :success
    products = assigns(:products)
    assert products.any?, 'Should find products matching name'
    assert(products.all? { |p| p.name.downcase.include?('chopped') || p.name.downcase.include?('strand') })
  end

  test 'should search products by description' do
    get search_url, params: { q: 'square meter' }
    assert_response :success
    products = assigns(:products)
    assert products.any?, 'Should find products matching description'
  end

  test 'should search products by category name' do
    get search_url, params: { q: 'Woven Roving' }
    assert_response :success
    products = assigns(:products)
    assert products.any?, 'Should find products in matching category'
  end

  test 'should display search query in URL' do
    get search_url, params: { q: 'test query' }
    assert_response :success
    assert_equal 'test query', assigns(:query)
  end

  test 'should show no results message when nothing found' do
    get search_url, params: { q: 'xyznonexistentproduct123' }
    assert_response :success
    assert_match 'No Products Found', response.body
  end

  test 'should only return active products' do
    get search_url, params: { q: 'Mat' }
    assert_response :success
    products = assigns(:products)
    assert products.all?(&:active?), 'All search results should be active products'
  end

  test 'should filter search results by minimum price' do
    get search_url, params: { q: 'Mat', min: 2000 }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.price >= 2000 }, 'All products should be >= min price'
  end

  test 'should filter search results by maximum price' do
    get search_url, params: { q: 'Mat', max: 2000 }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.price <= 2000 }, 'All products should be <= max price'
  end

  test 'should filter search results by price range' do
    get search_url, params: { q: 'Mat', min: 1000, max: 2000 }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.price.between?(1000, 2000) }, 'All products should be within price range'
  end

  test 'should filter search results by category' do
    get search_url, params: { q: 'Mat', category_id: @category_one.id }
    assert_response :success
    products = assigns(:products)
    assert products.all? { |p| p.category_id == @category_one.id }, 'All products should be in specified category'
  end

  test 'should load categories for filter dropdown' do
    get search_url, params: { q: 'Mat' }
    assert_response :success
    categories = assigns(:categories)
    assert_not_nil categories
  end

  test 'should handle empty search query gracefully' do
    get search_url, params: { q: '' }
    assert_response :success
    products = assigns(:products)
    assert products.empty? || products.is_a?(ActiveRecord::Relation), 'Should handle empty query'
  end

  test 'should handle whitespace-only search query' do
    get search_url, params: { q: '   ' }
    assert_response :success
    products = assigns(:products)
    assert products.empty? || products.is_a?(ActiveRecord::Relation), 'Should handle whitespace query'
  end

  test 'should preserve search query in filter form' do
    get search_url, params: { q: 'test search' }
    assert_response :success
    assert_select 'input[name="q"][value="test search"]', true
  end

  test 'should include breadcrumb navigation' do
    get search_url
    assert_select 'nav'
  end

  test 'search route should be accessible via GET' do
    assert_routing({ path: 'search', method: :get },
                   { controller: 'search', action: 'index' })
  end

  test 'should eager load product images' do
    get search_url, params: { q: 'Mat' }
    assert_response :success
    products = assigns(:products)
    products.each do |product|
      assert product.association(:images_attachments).loaded?, 'Images should be eager loaded'
    end
  end

  test 'should include product category in results' do
    get search_url, params: { q: 'Mat' }
    assert_response :success
    products = assigns(:products)
    products.each do |product|
      assert product.association(:category).loaded?, 'Category should be eager loaded'
    end
  end

  test 'should handle combined filters with search' do
    get search_url, params: { q: 'Mat', min: 1000, max: 3000, category_id: @category_one.id }
    assert_response :success
    products = assigns(:products)
    products.each do |product|
      assert product.active?, 'Product should be active'
      assert product.price.between?(1000, 3000), 'Product should be in price range'
      assert_equal @category_one.id, product.category_id, 'Product should be in specified category'
    end
  end

  test 'should display result count' do
    get search_url, params: { q: 'Mat' }
    assert_response :success
    assert_match 'product', response.body.downcase
  end

  test 'search is case insensitive' do
    get search_url, params: { q: 'CHOPPED STRAND' }
    assert_response :success
    products_upper = assigns(:products).to_a

    get search_url, params: { q: 'chopped strand' }
    assert_response :success
    products_lower = assigns(:products).to_a

    assert_equal products_upper.map(&:id).sort, products_lower.map(&:id).sort, 'Search should be case insensitive'
  end

  test 'should support prefix search' do
    get search_url, params: { q: 'Chop' }
    assert_response :success
    products = assigns(:products)
    assert products.any?, 'Prefix search should return results'
  end

  test 'should display pagination when results exceed page limit' do
    # This test depends on having more products than the page limit (12)
    get search_url, params: { q: 'Mat' }
    assert_response :success
    pagy = assigns(:pagy)
    assert_not_nil pagy, 'Pagination should be initialized for non-empty results'
  end
end
