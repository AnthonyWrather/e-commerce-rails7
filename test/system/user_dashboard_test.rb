# frozen_string_literal: true

require 'application_system_test_case'

class UserDashboardTest < ApplicationSystemTestCase
  setup do
    @user = users(:user_one)
  end

  test 'user can view dashboard when logged in' do
    sign_in @user
    visit account_path

    assert_selector 'h1', text: 'Account Dashboard'
    assert_text @user.full_name
    assert_text @user.email
  end

  test 'dashboard shows profile card with user information' do
    sign_in @user
    visit account_path

    within('.bg-white.rounded-lg.shadow.p-6', match: :first) do
      assert_text 'Profile'
      assert_text @user.full_name
      assert_text @user.email
    end
  end

  test 'dashboard shows primary address when available' do
    sign_in @user
    visit account_path

    assert_text 'Primary Address'
    assert_text addresses(:home_address).line1
  end

  test 'user can navigate to edit profile from dashboard' do
    sign_in @user
    visit account_path

    click_link 'Edit', match: :first
    assert_selector 'h1', text: 'Edit Profile'
  end

  test 'user can update their profile' do
    sign_in @user
    visit edit_account_path

    fill_in 'Full Name', with: 'Jane Updated'
    fill_in 'Phone Number', with: '+44 20 9999 8888'
    click_button 'Save Changes'

    assert_text 'Profile updated successfully.'
    assert_text 'Jane Updated'
  end

  test 'dashboard shows account stats' do
    sign_in @user
    visit account_path

    assert_text 'Account Summary'
    assert_text 'Total Orders'
    assert_text 'Saved Addresses'
    assert_text 'Member Since'
  end

  test 'sidebar navigation works correctly' do
    sign_in @user
    visit account_path

    # Navigate to addresses
    click_link 'Addresses'
    assert_selector 'h1', text: 'My Addresses'

    # Navigate to orders
    click_link 'Order History'
    assert_selector 'h1', text: 'Order History'

    # Navigate back to dashboard
    click_link 'Dashboard'
    assert_selector 'h1', text: 'Account Dashboard'
  end
end
