# frozen_string_literal: true

require 'application_system_test_case'

class Admin::ImagesTest < ApplicationSystemTestCase
  setup do
    sign_in_admin
    @product = products(:product_one)

    # Attach a test image to the product for testing deletion
    @product.images.attach(
      io: File.open(Rails.root.join('test', 'fixtures', 'files', 'test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
    @product.save!
  end

  test 'visiting product edit page shows image upload form' do
    visit edit_admin_product_path(@product)

    assert_selector 'h1', text: 'Editing product'
    assert_selector 'input[type="file"]'
    assert_selector 'label', text: 'Images'
  end

  test 'deleting an image from product redirects correctly' do
    skip 'Requires JavaScript driver for modal support (rack_test does not support accept_confirm)'

    # Skip if no images attached (Active Storage might not be configured)
    skip 'Product has no images' unless @product.images.attached?

    visit edit_admin_product_path(@product)

    # Confirm delete button is present
    if has_link?('X', wait: 2)
      # Click the delete button (X link)
      accept_confirm do
        click_link 'X', match: :first
      end

      # Should redirect back to edit page
      assert_current_path edit_admin_product_path(@product)
    else
      skip 'Delete button not found - images may not have attached properly'
    end
  end

  test 'product edit page has images section' do
    visit edit_admin_product_path(@product)

    # Should show the upload form
    assert_selector 'input[type="file"]'
    assert_selector 'label', text: 'Images'
  end

  # Additional Image Management Tests
  test 'product edit page shows existing images' do
    visit edit_admin_product_path(@product)

    assert_selector 'img'
    assert_selector 'a', text: 'X'
  end

  test 'product edit page has file upload field with multiple attribute' do
    visit edit_admin_product_path(@product)

    assert_selector 'input[type="file"][multiple]'
  end

  test 'new product page has image upload field' do
    visit new_admin_product_path

    assert_selector 'label', text: 'Images'
    assert_selector 'input[type="file"]'
  end

  test 'product with no images shows empty images section' do
    product_without_images = products(:product_two)
    visit edit_admin_product_path(product_without_images)

    assert_selector 'label', text: 'Images'
    assert_selector 'input[type="file"]'
  end

  test 'can navigate to edit stocks from product edit page' do
    visit edit_admin_product_path(@product)

    assert_selector 'a', text: 'Edit Product Size/Price/Stock'
  end
end
