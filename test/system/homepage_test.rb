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

  test 'homepage displays category images' do
    visit root_url

    # Check that category images are displayed (if they have images)
    assert_selector 'img', minimum: 1
  end

  test 'homepage has proper meta title' do
    visit root_url

    # Check that page has a title
    assert_title(/Southcoast|Fibreglass|E-?Commerce|Home|Store/i)
  end

  test 'homepage newsletter form is present' do
    visit root_url

    # Newsletter signup should be available
    assert_selector 'input[type="email"]', minimum: 1
  end

  test 'can navigate to contact page from homepage' do
    visit root_url

    click_on 'Contact Us'

    assert_current_path contact_path
  end

  test 'category cards are clickable' do
    visit root_url

    # Find a category card and verify it's a link
    category_link = find('a', text: 'Chop Strand Mat', match: :first)
    assert category_link.present?
  end

  test 'homepage displays multiple categories' do
    visit root_url

    # Should display at least 2 categories
    assert_selector 'a[href^="/categories/"]', minimum: 2
  end
end
