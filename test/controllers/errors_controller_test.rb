# frozen_string_literal: true

require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test 'should render 404 page' do
    get errors_not_found_path
    assert_response 404
    assert_select 'h1', '404'
    assert_select 'code', /ERR-[A-F0-9]{12}/
  end

  test 'should render 422 page' do
    get errors_unprocessable_entity_path
    assert_response 422
    assert_select 'h1', '422'
    assert_select 'code', /ERR-[A-F0-9]{12}/
  end

  test 'should render 500 page' do
    get errors_internal_server_error_path
    assert_response 500
    assert_select 'h1', '500'
    assert_select 'code', /ERR-[A-F0-9]{12}/
  end

  test '404 page should return JSON with error_id' do
    get errors_not_found_path, headers: { 'Accept' => 'application/json' }
    assert_response 404
    json_response = JSON.parse(response.body)
    assert_equal 'Not Found', json_response['error']
    assert_match(/ERR-[A-F0-9]{12}/, json_response['error_id'])
  end

  test '422 page should return JSON with error_id' do
    get errors_unprocessable_entity_path, headers: { 'Accept' => 'application/json' }
    assert_response 422
    json_response = JSON.parse(response.body)
    assert_equal 'Unprocessable Entity', json_response['error']
    assert_match(/ERR-[A-F0-9]{12}/, json_response['error_id'])
  end

  test '500 page should return JSON with error_id' do
    get errors_internal_server_error_path, headers: { 'Accept' => 'application/json' }
    assert_response 500
    json_response = JSON.parse(response.body)
    assert_equal 'Internal Server Error', json_response['error']
    assert_match(/ERR-[A-F0-9]{12}/, json_response['error_id'])
  end

  test '404 page should have links to home and contact' do
    get errors_not_found_path
    assert_select "a[href='#{root_path}']"
    assert_select "a[href='#{contact_path}']"
  end

  test '500 page should have links to home and contact' do
    get errors_internal_server_error_path
    assert_select "a[href='#{root_path}']"
    assert_select "a[href='#{contact_path}']"
  end
end
