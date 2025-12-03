# frozen_string_literal: true

require 'test_helper'

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in admin_users(:admin_user_one)
    @product = products(:product_one)
    # Attach a test image using Active Storage
    @product.images.attach(
      io: File.open(Rails.root.join('test', 'fixtures', 'files', 'test_image.png')),
      filename: 'test_image.png',
      content_type: 'image/png'
    )
  end

  test 'should destroy image' do
    assert_difference('@product.images.count', -1) do
      delete admin_product_image_url(@product, @product.images.first.id)
    end
    assert_redirected_to edit_admin_product_url(@product)
    assert_equal 'Image was successfully deleted.', flash[:notice]
  end
end
