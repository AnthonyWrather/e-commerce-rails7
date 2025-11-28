# frozen_string_literal: true

require 'application_system_test_case'

class CategoriesTest < ApplicationSystemTestCase
  setup do
    @category = categories(:category_one)
  end

  test 'visiting a category page' do
    visit category_url(@category)

    assert_selector 'h2', text: 'Filter'
    # Category pages show products, not description
    assert_selector 'form'
  end

  test 'category page displays products' do
    visit category_url(@category)

    # Products from this category should be displayed as links
    assert_link href: product_path(products(:product_one))
    assert_text products(:product_one).name
  end

  test 'category page displays breadcrumbs' do
    visit category_url(@category)

    assert_link 'Home'
    assert_text @category.name
  end

  test 'can navigate to product from category' do
    visit category_url(@category)

    click_on products(:product_one).name

    assert_current_path product_path(products(:product_one))
  end

  test 'category page has price filter' do
    visit category_url(@category)

    # Check for filter form elements
    assert_selector 'input[name="min"]'
    assert_selector 'input[name="max"]'
    assert_button 'Filter'
  end

  test 'can filter products by price range' do
    visit category_url(@category)

    fill_in 'min', with: '1000'
    fill_in 'max', with: '2000'
    click_button 'Filter'

    # Verify we're still on the category page (filter submitted)
    assert_current_path(%r{/categories/\d+})
  end

  test 'can clear price filters' do
    visit category_url(@category, min: '1000', max: '2000')

    # Verify filters are in URL initially
    assert_includes current_url, 'min=1000'

    click_on 'Clear'

    # Verify we're still on the category page
    assert_current_path(%r{/categories/\d+})
  end
end
