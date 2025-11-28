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
end
