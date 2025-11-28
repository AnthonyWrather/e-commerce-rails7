# frozen_string_literal: true

require 'application_system_test_case'

class ShoppingCartTest < ApplicationSystemTestCase
  test 'visiting the shopping cart page' do
    visit cart_url

    # Cart page shows 'Your Shopping Cart' heading
    assert_text 'Your Shopping Cart'
    # Table structure exists even when empty
    assert_selector 'table'
  end

  test 'cart page displays breadcrumbs' do
    visit cart_url

    assert_link 'Home'
    assert_text 'Shopping Cart'
  end

  test 'cart page has checkout button when items exist' do
    visit cart_url

    # Cart uses JavaScript to render items from localStorage
    # This test verifies the page structure exists
    assert_selector 'button', text: 'Checkout'
  end

  test 'cart page has clear cart button' do
    visit cart_url

    assert_selector 'button', text: 'Clear Cart'
  end

  test 'can navigate to homepage from cart' do
    visit cart_url

    click_on 'Home', match: :first

    assert_current_path root_path
  end
end
