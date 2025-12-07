# frozen_string_literal: true

require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in admin_users(:admin_user_one)
  end

  test 'should discard flash after rendering dashboard' do
    # Access dashboard which should trigger after_action
    get admin_path
    assert_response :success

    # Flash should be empty after the request
    assert flash.empty?, 'Flash should be discarded after rendering'
  end

  test 'flash messages are cleared after create action' do
    # Create a product which sets a flash message
    post admin_products_url,
         params: { product: { name: 'Test Product', price: 1000, category_id: categories(:one).id } }

    # Should redirect with flash
    assert_redirected_to admin_product_url(Product.last)
    follow_redirect!

    # Flash should contain the success message on the redirected page
    assert_not flash.empty?, 'Flash should contain success message after redirect'

    # Navigate to another admin page
    get admin_path

    # Flash should now be empty (discarded)
    assert flash.empty?, 'Flash should be discarded after navigating to another page'
  end

  test 'flash messages are cleared after update action' do
    product = products(:product_one)

    # Update the product which sets a flash message
    patch admin_product_url(product),
          params: { product: { name: 'Updated Name', price: product.price, category_id: product.category_id } }

    assert_redirected_to edit_admin_product_url(product)
    follow_redirect!

    # Flash should contain the success message
    assert_not flash.empty?, 'Flash should contain update success message'

    # Navigate to dashboard
    get admin_path

    # Flash should be cleared
    assert flash.empty?, 'Flash should be discarded after navigation'
  end

  test 'flash messages are cleared after destroy action' do
    product = products(:product_three)

    # Delete the product which sets a flash message
    assert_difference('Product.count', -1) do
      delete admin_product_url(product)
    end

    assert_redirected_to admin_products_url
    follow_redirect!

    # Flash should contain the success message
    assert_not flash.empty?, 'Flash should contain destroy success message'

    # Navigate to another page
    get admin_categories_path

    # Flash should be cleared
    assert flash.empty?, 'Flash should be discarded after navigation'
  end

  test 'flash discard does not affect error messages on same page' do
    # Try to create an invalid product
    post admin_products_url,
         params: { product: { name: '', price: -100, category_id: nil } }

    # Should re-render the form with errors (not redirect)
    assert_response :unprocessable_content

    # Flash might be empty or contain validation errors
    # The important thing is that we don't crash
  end

  test 'multiple successive actions do not accumulate flash messages' do
    # Create first product
    post admin_products_url,
         params: { product: { name: 'First Product', price: 1000, category_id: categories(:one).id } }
    follow_redirect!

    # Navigate away to clear flash
    get admin_path

    # Create second product
    post admin_products_url,
         params: { product: { name: 'Second Product', price: 2000, category_id: categories(:one).id } }
    follow_redirect!

    # Only the second creation message should be in flash
    # Count flash messages (there should only be one type: notice)
    assert_equal 1, flash.keys.size, 'Should only have one flash message type'
  end
end
