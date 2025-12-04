# frozen_string_literal: true

require 'test_helper'

class Admin::DataManagementControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in admin_users(:admin_user_one)
    @category = categories(:category_one)
    @product = products(:product_one)
    @stock = stocks(:stock_one)
  end

  test 'should get index' do
    get admin_data_management_index_url
    assert_response :success
    assert_select 'h1', 'Data Management'
  end

  test 'should require authentication for index' do
    sign_out :admin_user
    get admin_data_management_index_url
    assert_redirected_to new_admin_user_session_path
  end

  test 'should export all tables' do
    post export_admin_data_management_index_url, params: { tables: %w[categories products stocks] }
    assert_response :success
    assert_equal 'application/json', response.content_type

    data = JSON.parse(response.body)
    assert data.key?('categories')
    assert data.key?('products')
    assert data.key?('stocks')
  end

  test 'should export single table' do
    post export_admin_data_management_index_url, params: { tables: ['categories'] }
    assert_response :success

    data = JSON.parse(response.body)
    assert data.key?('categories')
    assert_not data.key?('products')
    assert_not data.key?('stocks')
  end

  test 'should export with default all tables when no tables specified' do
    post export_admin_data_management_index_url
    assert_response :success

    data = JSON.parse(response.body)
    assert data.key?('categories')
    assert data.key?('products')
    assert data.key?('stocks')
  end

  test 'should redirect on clear when no tables selected' do
    delete clear_admin_data_management_index_url, params: { tables: [] }
    assert_redirected_to admin_data_management_index_path
    assert_equal 'Please select at least one table', flash[:error]
  end

  test 'should clear stocks only' do
    initial_category_count = Category.count
    initial_product_count = Product.count
    initial_stock_count = Stock.count
    assert initial_stock_count.positive?, 'Test requires stocks to exist'

    delete clear_admin_data_management_index_url, params: { tables: ['stocks'] }

    assert_redirected_to admin_data_management_index_path
    assert_equal initial_category_count, Category.count
    assert_equal initial_product_count, Product.count
    assert_equal 0, Stock.count
    assert_includes flash[:notice], 'stocks'
  end

  test 'should redirect on import when no file provided' do
    post import_admin_data_management_index_url
    assert_redirected_to admin_data_management_index_path
    assert_equal 'Please select a file to import', flash[:error]
  end

  test 'should handle invalid JSON file on import' do
    invalid_file = Rack::Test::UploadedFile.new(
      StringIO.new('invalid json'),
      'application/json',
      original_filename: 'invalid.json'
    )

    post import_admin_data_management_index_url, params: { import_file: invalid_file }
    assert_redirected_to admin_data_management_index_path
    assert_includes flash[:error], 'Invalid JSON file'
  end

  test 'should import valid data' do
    # First, export existing data
    post export_admin_data_management_index_url, params: { tables: ['categories'] }
    exported_data = response.body

    # Create a new category in the export data with a unique name
    data = JSON.parse(exported_data)
    data['categories'] = [{
      'name' => 'Imported Category Test',
      'description' => 'A test category from import'
    }]

    import_file = Rack::Test::UploadedFile.new(
      StringIO.new(JSON.generate(data)),
      'application/json',
      original_filename: 'import.json'
    )

    assert_difference('Category.count', 1) do
      post import_admin_data_management_index_url, params: { import_file: import_file }
    end

    assert_redirected_to admin_data_management_index_path
    assert_includes flash[:notice], 'Successfully imported'
    assert Category.find_by(name: 'Imported Category Test')
  end

  test 'should show record counts in export view' do
    get admin_data_management_index_url
    assert_response :success
    assert_match(/Categories \(\d+\)/, response.body)
    assert_match(/Products \(\d+\)/, response.body)
    assert_match(/Stocks \(\d+\)/, response.body)
  end

  test 'should handle import with many errors without cookie overflow' do
    # Create import data with many invalid records that will generate errors
    data = {
      'categories' => (1..20).map { { 'name' => '' } }, # Invalid: blank names
      'products' => (1..20).map { |i| { 'name' => "Product #{i}", 'category_name' => 'NonExistent' } }
    }

    import_file = Rack::Test::UploadedFile.new(
      StringIO.new(JSON.generate(data)),
      'application/json',
      original_filename: 'import.json'
    )

    # This should not raise ActionDispatch::Cookies::CookieOverflow
    assert_nothing_raised do
      post import_admin_data_management_index_url, params: { import_file: import_file }
    end

    assert_redirected_to admin_data_management_index_path

    # Flash message should be truncated and manageable
    error_message = flash[:error]
    assert error_message.present?, 'Expected error flash message'
    assert error_message.length <= FlashMessageSanitizer::MAX_MESSAGE_SIZE,
           "Error message too long: #{error_message.length} characters"
  end

  test 'format_errors_for_flash is available in controller' do
    # Verify the controller has access to the format_errors_for_flash method
    controller = Admin::DataManagementController.new
    assert controller.respond_to?(:format_errors_for_flash, true)
  end
end
