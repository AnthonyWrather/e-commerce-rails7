# frozen_string_literal: true

require 'application_system_test_case'

class CheckoutsTest < ApplicationSystemTestCase
  test 'visiting the success page after checkout' do
    visit success_path

    # Check for success message
    assert_selector 'p', text: 'Your order was successfully placed'
    assert_selector 'p', text: 'Please contact us if you have any questions'
  end

  test 'success page displays order summary table' do
    visit success_path

    # Check for table headers
    assert_selector 'th', text: 'Item'
    assert_selector 'th', text: 'Size'
    assert_selector 'th', text: 'Price'
    assert_selector 'th', text: 'Quantity'
    assert_selector 'th', text: 'Item Total'
  end

  test 'success page has order again button' do
    visit success_path

    # Check for action buttons
    assert_selector 'button', text: 'Order Again'
    assert_selector 'button', text: 'Clear Cart'
  end

  test 'success page clears cart on load' do
    visit success_path

    # The page should have data-action to clear cart
    assert_selector '[data-action="cart#clear"]'
  end

  test 'visiting the cancel page' do
    visit cancel_path

    # Check for error messages
    assert_selector 'p', text: 'This order was not placed'
    assert_selector 'p', text: 'Your order was NOT placed'
    assert_selector 'p', text: 'Please contact us to resolve this issue'
  end

  test 'cancel page displays error styling' do
    visit cancel_path

    # Check for red text indicating error
    assert_selector 'p.text-red-700', text: 'This order was not placed'
  end

  test 'navigation from cart to cancel page' do
    # First visit cart
    visit cart_path

    # Then navigate to cancel (simulating a cancelled checkout)
    visit cancel_path

    assert_current_path cancel_path
    assert_selector 'p', text: 'This order was not placed'
  end
end
