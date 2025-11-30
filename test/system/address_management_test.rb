# frozen_string_literal: true

require 'application_system_test_case'

class AddressManagementTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test 'user can view their addresses' do
    visit addresses_path

    assert_selector 'h1', text: 'My Addresses'
    assert_text addresses(:home_address).label
    assert_text addresses(:work_address).label
  end

  test 'user can add a new address' do
    visit addresses_path
    click_link 'Add New Address'

    assert_selector 'h1', text: 'Add New Address'

    fill_in 'Address Label', with: 'Holiday Home'
    fill_in 'Full Name', with: 'John Smith'
    fill_in 'Address Line 1', with: '42 Beach Road'
    fill_in 'City / Town', with: 'Brighton'
    fill_in 'Postcode', with: 'BN1 1AA'

    click_button 'Save Address'

    assert_text 'Address added successfully.'
    assert_text 'Holiday Home'
  end

  test 'user can edit an existing address' do
    visit addresses_path

    # Find the address card by its unique heading
    within('div.bg-white.rounded-lg.shadow', text: 'Work') do
      click_link 'Edit'
    end

    assert_selector 'h1', text: 'Edit Address'

    fill_in 'Address Label', with: 'Updated Work'
    click_button 'Update Address'

    assert_text 'Address updated successfully.'
    assert_text 'Updated Work'
  end

  test 'primary badge is shown on primary address' do
    visit addresses_path

    assert_selector 'span', text: 'Primary'
  end

  test 'validation error shown for invalid postcode' do
    visit new_address_path

    fill_in 'Address Label', with: 'Test'
    fill_in 'Full Name', with: 'Test User'
    fill_in 'Address Line 1', with: '123 Test St'
    fill_in 'City / Town', with: 'London'
    fill_in 'Postcode', with: 'INVALID'

    click_button 'Save Address'

    assert_text 'is not a valid UK postcode format'
  end

  test 'user can navigate back to dashboard from addresses' do
    visit addresses_path

    click_link 'Dashboard'
    assert_selector 'h1', text: 'Account Dashboard'
  end
end
