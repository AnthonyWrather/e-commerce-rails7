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

    test 'should update admin_product with stock_level' do
      new_stock_level = 42
      patch admin_product_url(@admin_product),
            params: { product: { name: @admin_product.name, price: @admin_product.price,
                                 category_id: @admin_product.category_id, stock_level: new_stock_level } }
      assert_redirected_to edit_admin_product_url(@admin_product)
      @admin_product.reload
      assert_equal new_stock_level, @admin_product.stock_level
    end

    test 'should destroy admin_product' do
      product_to_delete = products(:product_three)
      assert_difference('Product.count', -1) do
        delete admin_product_url(product_to_delete)
      end

      assert_redirected_to admin_products_url
    end

    test 'should set notice flash on create' do
      post admin_products_url,
           params: { product: { active: true, category_id: @admin_product.category_id,
                                description: 'Flash test', name: 'Flash Test Product', price: 100 } }

      assert_equal 'Product was successfully created.', flash[:notice]
    end

    test 'should set notice flash on update' do
      patch admin_product_url(@admin_product),
            params: { product: { name: 'Updated Product Name', price: @admin_product.price,
                                 category_id: @admin_product.category_id } }

      assert_equal 'Product was successfully updated.', flash[:notice]
    end

    test 'should set notice flash on destroy' do
      product_to_delete = products(:product_three)
      delete admin_product_url(product_to_delete)

      assert_equal 'Product was successfully destroyed.', flash[:notice]
    end

    test 'flash messages are logged in audit logs via paper_trail' do
      # Create a product and check that PaperTrail logged the creation
      assert_difference('PaperTrail::Version.count') do
        post admin_products_url,
             params: { product: { active: true, category_id: @admin_product.category_id,
                                  description: 'Audit test', name: 'Audit Test Product', price: 200 } }
      end

      version = PaperTrail::Version.last
      assert_equal 'create', version.event
      assert_equal 'Product', version.item_type
    end
  end
end
