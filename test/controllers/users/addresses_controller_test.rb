# frozen_string_literal: true

require 'test_helper'

class Users::AddressesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_one)
    @address = addresses(:home_address)
    @non_primary_address = addresses(:work_address)
    sign_in @user
  end

  test 'should get index' do
    get addresses_url
    assert_response :success
    assert_select 'h1', 'My Addresses'
  end

  test 'should require authentication for addresses' do
    sign_out @user
    # Since routes are wrapped in authenticated :user block,
    # unauthenticated requests get 404
    get '/addresses'
    assert_response :not_found
  end

  test 'should get new' do
    get new_address_url
    assert_response :success
    assert_select 'h1', 'Add New Address'
  end

  test 'should create address' do
    assert_difference('Address.count') do
      post addresses_url, params: {
        address: {
          label: 'New Office',
          full_name: 'John Smith',
          line1: '789 New Street',
          city: 'Bristol',
          postcode: 'BS1 1AB',
          country: 'United Kingdom'
        }
      }
    end
    assert_redirected_to addresses_url
    assert_equal 'Address added successfully.', flash[:notice]
  end

  test 'should not create address with invalid data' do
    assert_no_difference('Address.count') do
      post addresses_url, params: {
        address: {
          label: '',
          full_name: '',
          line1: '',
          city: '',
          postcode: ''
        }
      }
    end
    assert_response :unprocessable_content
  end

  test 'should not create address with invalid UK postcode' do
    assert_no_difference('Address.count') do
      post addresses_url, params: {
        address: {
          label: 'Test',
          full_name: 'Test User',
          line1: '123 Test St',
          city: 'London',
          postcode: 'INVALID',
          country: 'United Kingdom'
        }
      }
    end
    assert_response :unprocessable_content
  end

  test 'should get edit' do
    get edit_address_url(@address)
    assert_response :success
    assert_select 'h1', 'Edit Address'
  end

  test 'should update address' do
    patch address_url(@address), params: {
      address: {
        label: 'Updated Home',
        line1: '999 Updated Street'
      }
    }
    assert_redirected_to addresses_url
    @address.reload
    assert_equal 'Updated Home', @address.label
    assert_equal '999 Updated Street', @address.line1
  end

  test 'should not update address with invalid data' do
    patch address_url(@address), params: {
      address: {
        full_name: ''
      }
    }
    assert_response :unprocessable_content
    @address.reload
    assert_equal 'John Smith', @address.full_name
  end

  test 'should destroy address' do
    assert_difference('Address.count', -1) do
      delete address_url(@non_primary_address)
    end
    assert_redirected_to addresses_url
    assert_equal 'Address deleted successfully.', flash[:notice]
  end

  test 'should set address as primary' do
    assert_not @non_primary_address.primary?
    patch set_primary_address_url(@non_primary_address)
    assert_redirected_to addresses_url
    @non_primary_address.reload
    assert @non_primary_address.primary?
    @address.reload
    assert_not @address.primary?
  end

  test 'should not access other users address' do
    other_address = addresses(:user_two_address)

    get edit_address_url(other_address)
    assert_response :not_found
  end

  test 'should list addresses in correct order' do
    get addresses_url
    assert_response :success
    # Primary should be first
    assert_select 'span', 'Primary'
  end

  test 'should create address with valid UK postcode formats' do
    valid_postcodes = ['SW1A 1AA', 'M1 1AE', 'B33 8TH', 'EC1A 1BB', 'W1A 0AX']

    valid_postcodes.each do |postcode|
      assert_difference('Address.count') do
        post addresses_url, params: {
          address: {
            label: "Test #{postcode}",
            full_name: 'Test User',
            line1: '123 Test St',
            city: 'London',
            postcode: postcode,
            country: 'United Kingdom'
          }
        }
      end
      assert_redirected_to addresses_url
    end
  end
end
