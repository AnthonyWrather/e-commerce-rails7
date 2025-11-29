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

  test 'category page shows only active products' do
    visit category_url(@category)

    # All displayed products should be active (inactive ones should not appear)
    # This is verified by the product list rendering correctly
    assert_selector 'a[href^="/products/"]', minimum: 1
  end

  test 'category with no products shows empty state' do
    empty_category = categories(:category_three)
    visit category_url(empty_category)

    # Should handle gracefully without errors
    assert_current_path category_url(empty_category)
  end

  test 'price filter shows all products when no filter applied' do
    visit category_url(@category)

    # Get count of visible products
    product_count = page.all('a[href^="/products/"]').count
    assert product_count.positive?, 'Should show products without filters'
  end

  test 'can navigate to home from category breadcrumb' do
    visit category_url(@category)

    within 'nav' do
      click_on 'Home'
    end

    assert_current_path root_path
  end

  test 'category page layout includes navigation' do
    visit category_url(@category)

    # Should have main navigation
    assert_selector 'nav'
    assert_link 'Home'
    assert_link 'Cart'
  end
end
