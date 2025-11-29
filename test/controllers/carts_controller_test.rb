# frozen_string_literal: true

require 'test_helper'

class CartsControllerTest < ActionDispatch::IntegrationTest
  test 'should get cart page' do
    get cart_url
    assert_response :success
  end

  test 'should render cart template' do
    get cart_url
    assert_template :show
  end

  test 'should have shopping cart breadcrumb' do
    get cart_url
    assert_select 'nav' # Breadcrumb navigation exists
  end

  test 'should display cart page without errors when no cart data' do
    # Cart is managed entirely in JavaScript/LocalStorage
    # This test ensures the page renders successfully
    get cart_url
    assert_response :success
    assert_select 'h1', text: /cart/i
  end

  test 'cart route should be accessible via GET' do
    assert_routing({ path: 'cart', method: :get },
                   { controller: 'carts', action: 'show' })
  end
end
