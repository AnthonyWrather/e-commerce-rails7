# frozen_string_literal: true

require 'test_helper'

class DataManagementServiceTest < ActiveSupport::TestCase
  def setup
    @service = DataManagementService.new
    @category = categories(:category_one)
    @product = products(:product_one)
    @stock = stocks(:stock_one)
  end

  test 'DataManagementService class exists' do
    assert DataManagementService
  end

  test 'DataManagementService defines DataManagementError exception' do
    assert DataManagementService::DataManagementError < StandardError
  end

  test 'TABLES constant includes expected tables' do
    assert_includes DataManagementService::TABLES, 'categories'
    assert_includes DataManagementService::TABLES, 'products'
    assert_includes DataManagementService::TABLES, 'stocks'
  end

  # Export tests
  test 'export returns hash with categories data' do
    data = @service.export(['categories'])

    assert data.key?('categories')
    assert data['categories'].is_a?(Array)
    assert data['categories'].any?
  end

  test 'export returns hash with products data' do
    data = @service.export(['products'])

    assert data.key?('products')
    assert data['products'].is_a?(Array)
    assert data['products'].any?
  end

  test 'export returns hash with stocks data' do
    data = @service.export(['stocks'])

    assert data.key?('stocks')
    assert data['stocks'].is_a?(Array)
    assert data['stocks'].any?
  end

  test 'export all tables returns complete data' do
    data = @service.export

    assert data.key?('categories')
    assert data.key?('products')
    assert data.key?('stocks')
  end

  test 'export category includes name and description' do
    data = @service.export(['categories'])
    category_data = data['categories'].find { |c| c['name'] == @category.name }

    assert_not_nil category_data
    assert_equal @category.name, category_data['name']
    assert_equal @category.description, category_data['description']
  end

  test 'export product includes category_name instead of category_id' do
    data = @service.export(['products'])
    product_data = data['products'].find { |p| p['name'] == @product.name }

    assert_not_nil product_data
    assert product_data.key?('category_name')
    assert_not product_data.key?('category_id')
    assert_equal @product.category.name, product_data['category_name']
  end

  test 'export stock includes product_name instead of product_id' do
    data = @service.export(['stocks'])
    stock_data = data['stocks'].find { |s| s['size'] == @stock.size }

    assert_not_nil stock_data
    assert stock_data.key?('product_name')
    assert_not stock_data.key?('product_id')
    assert_equal @stock.product.name, stock_data['product_name']
  end

  # Clear tests
  test 'clear stocks removes all stocks' do
    initial_stock_count = Stock.count
    assert initial_stock_count.positive?

    @service.clear(['stocks'])

    # All stocks should be removed (stocks have no order references)
    assert_equal 0, Stock.count
    assert(@service.results[:success].any? { |r| r[:table] == 'stocks' })
  end

  test 'clear products fails when products have orders' do
    # Products in fixtures are referenced by order_products, so clear should fail
    @service.clear(['products'])

    assert(@service.results[:errors].any? { |e| e[:table] == 'products' })
    assert(@service.results[:errors].any? { |e| e[:error].include?('orders') })
  end

  test 'clear categories fails when products have orders' do
    # Categories have products that are referenced by order_products
    @service.clear(['categories'])

    assert(@service.results[:errors].any? { |e| e[:table] == 'categories' })
    assert(@service.results[:errors].any? { |e| e[:error].include?('orders') })
  end

  test 'clear categories works when no order references exist' do
    # Clear order_products first to remove the constraint
    OrderProduct.delete_all
    Order.delete_all

    initial_count = Category.count
    assert initial_count.positive?

    @service.clear(['categories'])

    assert(@service.results[:success].any? { |r| r[:table] == 'categories' })
    assert_equal 0, Category.count
  end

  # Import tests
  test 'import creates new categories' do
    data = {
      'categories' => [
        { 'name' => 'Test Import Category Unique', 'description' => 'Test description' }
      ]
    }

    assert_difference('Category.count', 1) do
      @service.import(data)
    end

    assert Category.find_by(name: 'Test Import Category Unique')
    assert(@service.results[:success].any? { |r| r[:table] == 'categories' })
  end

  test 'import creates products with category reference' do
    # Create a unique category for this test
    unique_category = Category.create!(name: 'Import Test Cat Unique', description: 'Test')

    data = {
      'products' => [
        {
          'name' => 'Test Import Product Unique',
          'description' => 'Test product description',
          'price' => 1000,
          'active' => true,
          'category_name' => unique_category.name
        }
      ]
    }

    assert_difference('Product.count', 1) do
      @service.import(data)
    end

    product = Product.find_by(name: 'Test Import Product Unique')
    assert product
    assert_equal unique_category.name, product.category.name
  end

  test 'import creates stocks with product reference' do
    data = {
      'stocks' => [
        {
          'size' => 'Test Import Size Unique',
          'stock_level' => 100,
          'price' => 5000,
          'product_name' => @product.name,
          'category_name' => @product.category.name
        }
      ]
    }

    assert_difference('Stock.count', 1) do
      @service.import(data)
    end

    stock = Stock.find_by(size: 'Test Import Size Unique')
    assert stock
    assert_equal @product.name, stock.product.name
  end

  test 'import records errors for missing category reference' do
    data = {
      'products' => [
        {
          'name' => 'Product Without Category',
          'description' => 'Test',
          'price' => 1000,
          'active' => true,
          'category_name' => 'Non Existent Category XYZ123'
        }
      ]
    }

    @service.import(data)

    assert(@service.results[:errors].any? { |e| e[:table] == 'products' })
  end

  test 'import records errors for missing product reference in stocks' do
    data = {
      'stocks' => [
        {
          'size' => 'Test Size',
          'stock_level' => 100,
          'price' => 5000,
          'product_name' => 'Non Existent Product XYZ123',
          'category_name' => 'Non Existent Category'
        }
      ]
    }

    @service.import(data)

    assert(@service.results[:errors].any? { |e| e[:table] == 'stocks' })
  end

  test 'import continues after individual record errors' do
    data = {
      'categories' => [
        { 'name' => nil, 'description' => 'Test' }, # Invalid - will fail validation
        { 'name' => 'Valid Category For Continue Test', 'description' => 'Test' } # Valid - should succeed
      ]
    }

    @service.import(data)

    # Should have one error and one success
    assert @service.results[:errors].any?
    assert Category.find_by(name: 'Valid Category For Continue Test')
  end

  # Results tracking tests
  test 'results initialized with empty arrays' do
    service = DataManagementService.new
    assert_equal [], service.results[:success]
    assert_equal [], service.results[:errors]
  end

  test 'export tracks errors when table export fails' do
    # Test with an invalid table name - this should track an error
    service = DataManagementService.new
    service.export(['invalid_table'])

    assert service.results[:errors].any?
  end

  test 'clear tracks success for each cleared table' do
    @service.clear(%w[stocks])

    success_tables = @service.results[:success].map { |s| s[:table] }
    assert_includes success_tables, 'stocks'
  end
end
