# frozen_string_literal: true

require 'application_system_test_case'

class Admin::FlashMessagesTest < ApplicationSystemTestCase
  setup do
    sign_in_admin
  end

  test 'displays notice flash message on product creation' do
    visit new_admin_product_url

    category = categories(:category_one)
    fill_in 'Name', with: 'Test Product'
    fill_in 'Description', with: 'Test Description'
    fill_in 'Price', with: 1000
    select category.name, from: 'Category'
    click_on 'Create Product'

    assert_selector '#flash-messages', visible: true
    assert_text 'Product was successfully created'
  end

  test 'displays notice flash message on category creation' do
    visit new_admin_category_url

    fill_in 'Name', with: 'Unique Flash Test Category'
    fill_in 'Description', with: 'Test Category Description'
    click_on 'Create Category'

    assert_selector '#flash-messages', visible: true
    assert_text 'Category was successfully created'
  end

  test 'displays notice flash message after product destroy' do
    product = products(:product_three)
    visit admin_product_url(product)
    click_on 'Destroy this admin_product', match: :first

    assert_selector '#flash-messages', visible: true
    assert_text 'Product was successfully destroyed'
  end

  test 'displays notice flash message after category destroy' do
    category = categories(:category_three)
    visit admin_category_url(category)
    click_on 'Destroy this category', match: :first

    assert_selector '#flash-messages', visible: true
    assert_text 'Category was successfully destroyed'
  end

  test 'flash messages are properly styled with correct colors' do
    visit new_admin_product_url

    category = categories(:category_one)
    fill_in 'Name', with: 'Style Test Product'
    fill_in 'Description', with: 'Test Description'
    fill_in 'Price', with: 500
    select category.name, from: 'Category'
    click_on 'Create Product'

    assert_selector '#flash-messages div[role="alert"]'
    assert_selector '#flash-messages .bg-green-100'
  end
end
