# frozen_string_literal: true

require 'application_system_test_case'

module Admin
  class CategoriesTest < ApplicationSystemTestCase
    setup do
      sign_in_admin
      @admin_category = categories(:category_one)
    end

    test 'visiting the index' do
      visit admin_categories_url
      assert_selector 'h1', text: 'Categories'
    end

    test 'should create category' do
      visit admin_categories_url
      click_on 'New category'

      fill_in 'Description', with: @admin_category.description
      fill_in 'Name', with: 'Brand New Category Name'
      click_on 'Create Category'

      assert_text 'Category was successfully created'
      click_on 'Back'
    end

    test 'should update Category' do
      visit admin_category_url(@admin_category)
      click_on 'Edit this category', match: :first

      fill_in 'Description', with: @admin_category.description
      fill_in 'Name', with: @admin_category.name
      click_on 'Update Category'

      assert_text 'Category was successfully updated'
      click_on 'Back'
    end

    test 'should destroy Category' do
      category_to_destroy = categories(:category_three)
      visit admin_category_url(category_to_destroy)
      click_on 'Destroy this category', match: :first

      assert_text 'Category was successfully destroyed'
    end
  end
end
