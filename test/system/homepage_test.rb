# frozen_string_literal: true

require 'application_system_test_case'

class HomepageTest < ApplicationSystemTestCase
  test 'visiting the homepage' do
    visit root_url

    assert_selector 'h2', text: 'Welcome to our store'
    assert_text 'Chop Strand Mat'
    assert_text 'Woven Roving'
  end

  test 'homepage displays main categories' do
    visit root_url

    # Check that categories are displayed
    assert_selector 'a', text: 'Chop Strand Mat'
    assert_selector 'a', text: 'Woven Roving'
  end

  test 'can navigate to category from homepage' do
    visit root_url

    click_on 'Chop Strand Mat'

    assert_current_path category_path(categories(:category_one))
    assert_selector 'h2', text: 'Filter'
  end

  test 'homepage navigation links work' do
    visit root_url

    # Check navigation links are present
    assert_link 'Home'
    assert_link 'Contact Us'
    assert_link 'Cart'
  end
end
