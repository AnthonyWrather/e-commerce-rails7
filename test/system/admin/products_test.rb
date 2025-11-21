# frozen_string_literal: true

require 'application_system_test_case'

module Admin
  class ProductsTest < ApplicationSystemTestCase
    setup do
      sign_in_admin
      @admin_product = products(:product_one)
    end

    test 'visiting the index' do
      visit admin_products_url
      assert_selector 'h1', text: 'Products'
    end

    test 'should create product' do
      visit admin_products_url
      click_on 'New product'

      check 'Active' if @admin_product.active
      select @admin_product.category.name, from: 'Category'
      fill_in 'Description', with: @admin_product.description
      fill_in 'Name', with: @admin_product.name
      fill_in 'Price', with: @admin_product.price
      click_on 'Create Product'

      assert_text 'Product was successfully created'
      click_on 'Back'
    end

    test 'should update Product' do
      visit admin_product_url(@admin_product)
      click_on 'Edit this admin_product', match: :first

      check 'Active' if @admin_product.active
      select @admin_product.category.name, from: 'Category'
      fill_in 'Description', with: @admin_product.description
      fill_in 'Name', with: @admin_product.name
      fill_in 'Price', with: @admin_product.price
      find('input[type="submit"]').click

      assert_text 'Product updated successfully'
    end

    test 'should destroy Product' do
      product_to_destroy = products(:product_three)
      visit admin_product_url(product_to_destroy)
      click_on 'Destroy this admin_product', match: :first

      assert_text 'Product was successfully destroyed'
    end
  end
end
