# frozen_string_literal: true

require 'test_helper'

module Admin
  class ProductsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin_product = products(:product_one)
      sign_in admin_users(:admin_user_one)
    end

    test 'should get index' do
      get admin_products_url
      assert_response :success
    end

    test 'should get new' do
      get new_admin_product_url
      assert_response :success
    end

    test 'should create admin_product' do
      assert_difference('Product.count') do
        post admin_products_url,
             params: { product: { active: @admin_product.active, category_id: @admin_product.category_id,
                                  description: @admin_product.description, name: @admin_product.name, price: @admin_product.price } }
      end

      assert_redirected_to admin_product_url(Product.last)
    end

    test 'should show admin_product' do
      get admin_product_url(@admin_product)
      assert_response :success
    end

    test 'should get edit' do
      get edit_admin_product_url(@admin_product)
      assert_response :success
    end

    test 'should update admin_product' do
      patch admin_product_url(@admin_product),
            params: { product: { active: @admin_product.active, category_id: @admin_product.category_id,
                                 description: @admin_product.description, name: @admin_product.name, price: @admin_product.price } }
      assert_redirected_to edit_admin_product_url(@admin_product)
    end

    test 'should destroy admin_product' do
      product_to_delete = products(:product_three)
      assert_difference('Product.count', -1) do
        delete admin_product_url(product_to_delete)
      end

      assert_redirected_to admin_products_url
    end
  end
end
