# frozen_string_literal: true

require 'application_system_test_case'

class SearchTest < ApplicationSystemTestCase
  setup do
    @product_one = products(:product_one)
    @product_two = products(:product_two)
    @category_one = categories(:category_one)
  end

  test 'search box is visible in navbar' do
    visit root_url

    assert_selector 'input[type="search"]'
    assert_selector 'input[placeholder="Search products..."]'
  end

  test 'can search for products from homepage' do
    visit root_url

    fill_in 'Search products...', with: 'Chopped'
    find('button[aria-label="Search"]').click

    assert_current_path search_path, ignore_query: true
    assert_text 'Search Results'
    assert_text 'Chopped'
  end

  test 'search results show matching products' do
    visit search_path(q: 'Strand')

    assert_text 'Search Results for "Strand"'
    assert_text @product_one.name
  end

  test 'search results show product count' do
    visit search_path(q: 'Mat')

    assert_text(/Found \d+ products?/)
  end

  test 'empty search shows helpful message' do
    visit search_path

    assert_text 'Start Your Search'
    assert_text 'Enter a search term'
  end

  test 'no results shows helpful message' do
    visit search_path(q: 'xyznonexistent123')

    assert_text 'No Products Found'
    assert_text "couldn't find any products"
  end

  test 'search results have filter sidebar' do
    visit search_path(q: 'Mat')

    assert_text 'Filters'
    assert_selector 'input[name="min"]'
    assert_selector 'input[name="max"]'
    assert_selector 'select[name="category_id"]'
  end

  test 'can filter search results by price' do
    visit search_path(q: 'Mat')

    fill_in 'min', with: '1800'
    click_on 'Apply Filters'

    assert_current_path search_path, ignore_query: true
    # URL should contain min parameter
    assert_includes current_url, 'min=1800'
  end

  test 'search query is preserved in URL' do
    visit search_path(q: 'test search query')

    assert_includes current_url, 'q=test+search+query'
    assert_selector 'input[name="q"][value="test search query"]', visible: :all
  end

  test 'can click on search result to view product' do
    visit search_path(q: 'Chopped Strand')

    click_on @product_one.name

    assert_current_path product_path(@product_one)
  end

  test 'breadcrumbs show search path' do
    visit search_path(q: 'Mat')

    assert_text 'Home'
    assert_text 'Search'
  end

  test 'search is case insensitive' do
    visit search_path(q: 'CHOPPED')

    assert_text @product_one.name
  end

  test 'search supports prefix matching' do
    visit search_path(q: 'Chop')

    assert_text @product_one.name
  end
end
