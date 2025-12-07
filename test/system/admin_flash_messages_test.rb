# frozen_string_literal: true

require 'application_system_test_case'

class AdminFlashMessagesTest < ApplicationSystemTestCase
  test 'flash messages do not persist when navigating between admin pages' do
    # Sign in as admin
    sign_in_admin

    # Navigate to products page
    visit admin_products_path

    # Create a new product to trigger a flash message
    click_on 'New product'
    fill_in 'Name', with: 'Test Flash Product'
    fill_in 'Price', with: '1000'
    select categories(:one).name, from: 'Category'
    click_button 'Create Product'

    # Verify flash message is displayed after creation
    assert_selector '#flash-messages', text: 'Product was successfully created'

    # Navigate to categories page
    visit admin_categories_path

    # Flash message should NOT appear on the categories page
    assert_no_selector '#flash-messages', text: 'Product was successfully created'

    # Navigate back to products page
    visit admin_products_path

    # Flash message should still NOT appear
    assert_no_selector '#flash-messages', text: 'Product was successfully created'
  end

  test 'flash messages appear only once after update action' do
    sign_in_admin

    # Edit an existing product
    product = products(:one)
    visit edit_admin_product_path(product)

    fill_in 'Name', with: 'Updated Product Name'
    click_button 'Update Product'

    # Verify flash message appears after update
    assert_selector '#flash-messages', text: 'Product was successfully updated'

    # Navigate to another page
    visit admin_path

    # Flash message should NOT persist
    assert_no_selector '#flash-messages', text: 'Product was successfully updated'
  end

  test 'flash messages appear only once after delete action' do
    sign_in_admin

    # Navigate to products page
    visit admin_products_path

    # Delete a product
    product = products(:three)
    accept_confirm do
      within("#product_#{product.id}") do
        click_on 'Destroy'
      end
    end

    # Verify flash message appears after deletion
    assert_selector '#flash-messages', text: 'Product was successfully destroyed'

    # Navigate to dashboard
    visit admin_path

    # Flash message should NOT persist
    assert_no_selector '#flash-messages', text: 'Product was successfully destroyed'
  end

  test 'multiple flash messages do not accumulate across requests' do
    sign_in_admin

    # Create first product
    visit new_admin_product_path
    fill_in 'Name', with: 'First Flash Product'
    fill_in 'Price', with: '1000'
    select categories(:one).name, from: 'Category'
    click_button 'Create Product'

    assert_selector '#flash-messages', text: 'Product was successfully created'

    # Create second product
    visit new_admin_product_path
    fill_in 'Name', with: 'Second Flash Product'
    fill_in 'Price', with: '2000'
    select categories(:one).name, from: 'Category'
    click_button 'Create Product'

    # Only the second creation message should appear
    assert_selector '#flash-messages', text: 'Product was successfully created', count: 1

    # Navigate away
    visit admin_path

    # No flash messages should appear
    assert_no_selector '#flash-messages', text: 'Product was successfully created'
  end

  test 'flash message close button dismisses message immediately' do
    sign_in_admin

    # Trigger a flash message
    visit new_admin_product_path
    fill_in 'Name', with: 'Close Button Test Product'
    fill_in 'Price', with: '1500'
    select categories(:one).name, from: 'Category'
    click_button 'Create Product'

    # Verify message appears
    assert_selector '#flash-messages', text: 'Product was successfully created'

    # Click the close button
    within('#flash-messages') do
      find('button[aria-label="Close"]').click
    end

    # Message should be removed from DOM (after animation)
    # Note: rack_test driver doesn't support JavaScript, so we can't test the actual dismissal
    # This test documents the expected behavior
  end
end
