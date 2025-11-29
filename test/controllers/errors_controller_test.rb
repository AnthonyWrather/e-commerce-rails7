# frozen_string_literal: true

require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test 'should render 404 page' do
    get '/404'
    assert_response :not_found
    assert_select 'h1', '404'
    assert_select 'code', /ERR-[A-F0-9]{12}/
  end

  test 'should render 422 page' do
    get '/422'
    assert_response :unprocessable_entity
    assert_select 'h1', '422'
    assert_select 'code', /ERR-[A-F0-9]{12}/
  end

  test 'should render 500 page' do
    get '/500'
    assert_response :internal_server_error
    assert_select 'h1', '500'
    assert_select 'code', /ERR-[A-F0-9]{12}/
  end

  test '404 page should return JSON with error_id' do
    get '/404', headers: { 'Accept' => 'application/json' }
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal 'Not Found', json_response['error']
    assert_match(/ERR-[A-F0-9]{12}/, json_response['error_id'])
  end

  test '422 page should return JSON with error_id' do
    get '/422', headers: { 'Accept' => 'application/json' }
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal 'Unprocessable Entity', json_response['error']
    assert_match(/ERR-[A-F0-9]{12}/, json_response['error_id'])
  end

  test '500 page should return JSON with error_id' do
    get '/500', headers: { 'Accept' => 'application/json' }
    assert_response :internal_server_error
    json_response = JSON.parse(response.body)
    assert_equal 'Internal Server Error', json_response['error']
    assert_match(/ERR-[A-F0-9]{12}/, json_response['error_id'])
  end

  test '404 page should have links to home and contact' do
    get '/404'
    assert_select "a[href='#{root_path}']"
    assert_select "a[href='#{contact_path}']"
  end

  test '500 page should have links to home and contact' do
    get '/500'
    assert_select "a[href='#{root_path}']"
    assert_select "a[href='#{contact_path}']"
  end
end
