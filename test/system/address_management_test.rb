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

  # Additional Address Tests
  test 'user can delete an address' do
    visit addresses_path

    # Count initial addresses
    initial_count = page.all('div.bg-white.rounded-lg.shadow').count

    within('div.bg-white.rounded-lg.shadow', text: 'Work') do
      click_button 'Delete'
    end

    assert_text 'Address deleted successfully.'
    assert_equal initial_count - 1, page.all('div.bg-white.rounded-lg.shadow').count
  end

  test 'user can set address as primary' do
    visit addresses_path

    # Find the non-primary address and set it as primary
    within('div.bg-white.rounded-lg.shadow', text: 'Work') do
      click_button 'Set Primary'
    end

    assert_text 'Primary address updated successfully.'

    # Verify Work is now primary
    within('div.bg-white.rounded-lg.shadow', text: 'Work') do
      assert_selector 'span', text: 'Primary'
    end
  end

  test 'validation error shown for blank label' do
    visit new_address_path

    fill_in 'Address Label', with: ''
    fill_in 'Full Name', with: 'Test User'
    fill_in 'Address Line 1', with: '123 Test St'
    fill_in 'City / Town', with: 'London'
    fill_in 'Postcode', with: 'SW1A 1AA'

    click_button 'Save Address'

    assert_text "can't be blank"
  end

  test 'validation error shown for blank full name' do
    visit new_address_path

    fill_in 'Address Label', with: 'Test'
    fill_in 'Full Name', with: ''
    fill_in 'Address Line 1', with: '123 Test St'
    fill_in 'City / Town', with: 'London'
    fill_in 'Postcode', with: 'SW1A 1AA'

    click_button 'Save Address'

    assert_text "can't be blank"
  end

  test 'validation error shown for blank address line 1' do
    visit new_address_path

    fill_in 'Address Label', with: 'Test'
    fill_in 'Full Name', with: 'Test User'
    fill_in 'Address Line 1', with: ''
    fill_in 'City / Town', with: 'London'
    fill_in 'Postcode', with: 'SW1A 1AA'

    click_button 'Save Address'

    assert_text "can't be blank"
  end

  test 'validation error shown for blank city' do
    visit new_address_path

    fill_in 'Address Label', with: 'Test'
    fill_in 'Full Name', with: 'Test User'
    fill_in 'Address Line 1', with: '123 Test St'
    fill_in 'City / Town', with: ''
    fill_in 'Postcode', with: 'SW1A 1AA'

    click_button 'Save Address'

    assert_text "can't be blank"
  end

  test 'user can add address with optional fields' do
    visit addresses_path
    click_link 'Add New Address'

    fill_in 'Address Label', with: 'Complete Address'
    fill_in 'Full Name', with: 'John Smith'
    fill_in 'Address Line 1', with: '123 High Street'
    fill_in 'Address Line 2', with: 'Flat 4'
    fill_in 'City / Town', with: 'Manchester'
    fill_in 'County', with: 'Greater Manchester'
    fill_in 'Postcode', with: 'M1 2AB'
    fill_in 'Phone', with: '+44 161 234 5678'

    click_button 'Save Address'

    assert_text 'Address added successfully.'
    assert_text 'Complete Address'
    assert_text 'Flat 4'
  end

  test 'user can view add address page from empty state' do
    # Delete all addresses for user
    @user.addresses.destroy_all

    visit addresses_path

    click_link 'Add New Address'
    assert_selector 'h1', text: 'Add New Address'
  end

  test 'address list shows all required information' do
    visit addresses_path

    within('div.bg-white.rounded-lg.shadow', text: 'Home') do
      assert_text addresses(:home_address).full_name
      assert_text addresses(:home_address).line1
      assert_text addresses(:home_address).city
      assert_text addresses(:home_address).postcode
    end
  end

  test 'user can cancel address creation and return to list' do
    visit new_address_path

    click_link 'Cancel'
    assert_selector 'h1', text: 'My Addresses'
  end

  test 'user can cancel address edit and return to list' do
    visit addresses_path

    within('div.bg-white.rounded-lg.shadow', text: 'Work') do
      click_link 'Edit'
    end

    click_link 'Cancel'
    assert_selector 'h1', text: 'My Addresses'
  end

  test 'editing address shows prefilled data' do
    visit addresses_path

    within('div.bg-white.rounded-lg.shadow', text: 'Home') do
      click_link 'Edit'
    end

    assert_field 'Address Label', with: 'Home'
    assert_field 'Full Name', with: addresses(:home_address).full_name
    assert_field 'Address Line 1', with: addresses(:home_address).line1
  end
end
