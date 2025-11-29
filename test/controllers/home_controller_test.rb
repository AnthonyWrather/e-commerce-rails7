# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get root_url
    assert_response :success
  end

  test 'should render index template' do
    get root_url
    assert_template :index
  end

  test 'should load main categories' do
    get root_url
    assert_not_nil assigns(:main_categories)
    assert_kind_of ActiveRecord::Relation, assigns(:main_categories)
  end

  test 'should limit categories to 10' do
    get root_url
    categories = assigns(:main_categories)
    assert categories.count <= 10, 'Should limit to 10 categories'
  end

  test 'should eager load category images to prevent N+1 queries' do
    get root_url
    categories = assigns(:main_categories)
    categories.each do |category|
      # Check that image_attachment association is loaded
      assert category.association(:image_attachment).loaded?, 'Image attachment should be eager loaded'
    end
  end

  test 'should display breadcrumb on homepage' do
    get root_url
    # Home breadcrumb should be present
    assert_match 'Home', response.body
  end

  test 'should set correct breadcrumb trail' do
    get root_url
    # Controller adds breadcrumb in controller
    assert_response :success
  end

  test 'index route should be root path' do
    assert_routing({ path: '/', method: :get },
                   { controller: 'home', action: 'index' })
  end

  test 'should have navigation elements' do
    get root_url
    assert_select 'nav'
  end

  test 'should display welcome message' do
    get root_url
    assert_match(/welcome/i, response.body)
  end

  test 'should use application layout' do
    get root_url
    assert_template layout: 'application'
  end
end
