# frozen_string_literal: true

require 'test_helper'

class AssociationsTest < ActiveSupport::TestCase
  # Product associations
  test 'product belongs to category' do
    product = products(:product_one)
    assert_instance_of Category, product.category
    assert_equal categories(:category_one), product.category
  end

  test 'product has many stocks' do
    product = products(:product_one)
    assert_respond_to product, :stocks
    assert_kind_of ActiveRecord::Associations::CollectionProxy, product.stocks
  end

  test 'product has many order_products' do
    product = products(:product_one)
    assert_respond_to product, :order_products
    assert_kind_of ActiveRecord::Associations::CollectionProxy, product.order_products
  end

  test 'product can have multiple stocks with different sizes' do
    product = products(:product_one)
    
    stock1 = Stock.create!(product: product, size: 'Small', price: 1000)
    stock2 = Stock.create!(product: product, size: 'Large', price: 2000)
    
    assert_includes product.stocks.reload, stock1
    assert_includes product.stocks, stock2
    assert product.stocks.count >= 2
  end

  # Category associations
  test 'category has many products' do
    category = categories(:category_one)
    assert_respond_to category, :products
    assert_kind_of ActiveRecord::Associations::CollectionProxy, category.products
  end

  test 'deleting category destroys associated products' do
    category = categories(:category_three)
    
    # Create a product for this category
    product = Product.create!(
      name: 'Test Product for Deletion',
      price: 1000,
      category: category,
      active: true
    )
    
    product_id = product.id
    category_id = category.id
    
    category.destroy
    
    assert_nil Category.find_by(id: category_id)
    assert_nil Product.find_by(id: product_id)
  end

  # Stock associations
  test 'stock belongs to product' do
    stock = stocks(:stock_one)
    assert_instance_of Product, stock.product
    assert_equal products(:product_one), stock.product
  end

  # Order associations
  test 'order has many order_products' do
    order = orders(:order_one)
    assert_respond_to order, :order_products
    assert_kind_of ActiveRecord::Associations::CollectionProxy, order.order_products
  end

  test 'order can access products through order_products' do
    order = orders(:order_one)
    order_product = order.order_products.first
    
    if order_product
      assert_instance_of Product, order_product.product
    end
  end

  # OrderProduct associations
  test 'order_product belongs to product' do
    order_product = order_products(:order_product_one)
    assert_instance_of Product, order_product.product
  end

  test 'order_product belongs to order' do
    order_product = order_products(:order_product_one)
    assert_instance_of Order, order_product.order
  end

  # Complex association chain test
  test 'can traverse from category to orders through products and order_products' do
    category = categories(:category_one)
    product = category.products.first
    
    if product
      order_product = product.order_products.first
      
      if order_product
        order = order_product.order
        assert_instance_of Order, order
      end
    end
  end

  # Active Storage associations
  test 'product can have multiple attached images' do
    product = products(:product_one)
    assert_respond_to product, :images
  end

  test 'category can have one attached image' do
    category = categories(:category_one)
    assert_respond_to category, :image
  end
end
