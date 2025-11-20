# frozen_string_literal: true

require 'test_helper'

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:product_one)
  end

  test 'should destroy image' do
    skip 'Image deletion requires attached image with signed_id'
    # delete admin_product_image_url(@product, image.signed_id)
    # assert_redirected_to edit_admin_product_url(@product)
  end
end
