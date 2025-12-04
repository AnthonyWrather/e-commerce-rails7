# frozen_string_literal: true

require 'application_system_test_case'

class Admin::DataManagementTest < ApplicationSystemTestCase
  setup do
    @admin_user = admin_users(:admin_user_one)
    login_as(@admin_user, scope: :admin_user)
  end

  test 'visiting data management index' do
    visit admin_data_management_index_url

    assert_selector 'h1', text: 'Data Management'
    assert_selector 'h2', text: 'Export Data'
    assert_selector 'h2', text: 'Import Data'
    assert_selector 'h2', text: 'Clear Data'
  end

  test 'data management page shows record counts' do
    visit admin_data_management_index_url

    assert_text(/Categories \(\d+\)/)
    assert_text(/Products \(\d+\)/)
    assert_text(/Stocks \(\d+\)/)
  end

  test 'data management page shows checkboxes for table selection' do
    visit admin_data_management_index_url

    # Export section has checkboxes
    within('form[action*="export"]') do
      assert_selector "input[type='checkbox'][value='categories']"
      assert_selector "input[type='checkbox'][value='products']"
      assert_selector "input[type='checkbox'][value='stocks']"
    end

    # Clear section has checkboxes
    within('form[action*="clear"]') do
      assert_selector "input[type='checkbox'][value='categories']"
      assert_selector "input[type='checkbox'][value='products']"
      assert_selector "input[type='checkbox'][value='stocks']"
    end
  end

  test 'data management link is visible in sidebar' do
    visit admin_path

    assert_selector 'a[href*="data_management"]', text: 'Data Management'
  end
end
