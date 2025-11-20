# frozen_string_literal: true

require 'test_helper'

module Admin
  class CategoriesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin_category = categories(:category_one)
      sign_in admin_users(:admin_user_one)
    end

    test 'should get index' do
      get admin_categories_url
      assert_response :success
    end

    test 'should get new' do
      get new_admin_category_url
      assert_response :success
    end

    test 'should create admin_category' do
      assert_difference('Category.count') do
        post admin_categories_url,
             params: { category: { description: @admin_category.description, name: @admin_category.name } }
      end

      assert_redirected_to admin_category_url(Category.last)
    end

    test 'should show admin_category' do
      get admin_category_url(@admin_category)
      assert_response :success
    end

    test 'should get edit' do
      get edit_admin_category_url(@admin_category)
      assert_response :success
    end

    test 'should update admin_category' do
      patch admin_category_url(@admin_category),
            params: { category: { description: @admin_category.description, name: @admin_category.name } }
      assert_redirected_to admin_category_url(@admin_category)
    end

    test 'should destroy admin_category' do
      category_to_delete = categories(:category_three)
      assert_difference('Category.count', -1) do
        delete admin_category_url(category_to_delete)
      end

      assert_redirected_to admin_categories_url
    end
  end
end
