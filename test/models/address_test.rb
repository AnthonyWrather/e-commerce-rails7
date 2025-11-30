# frozen_string_literal: true

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_one)
    @address = addresses(:home_address)
  end

  test 'should be valid with all required attributes' do
    assert @address.valid?
  end

  test 'should belong to user' do
    assert_equal @user, @address.user
  end

  test 'should require user' do
    @address.user = nil
    assert_not @address.valid?
  end

  test 'should require label' do
    @address.label = nil
    assert_not @address.valid?
    assert_includes @address.errors[:label], "can't be blank"
  end

  test 'should reject label over 50 characters' do
    @address.label = 'A' * 51
    assert_not @address.valid?
    assert_includes @address.errors[:label], 'is too long (maximum is 50 characters)'
  end

  test 'should require full_name' do
    @address.full_name = nil
    assert_not @address.valid?
    assert_includes @address.errors[:full_name], "can't be blank"
  end

  test 'should require full_name minimum length of 2' do
    @address.full_name = 'A'
    assert_not @address.valid?
    assert_includes @address.errors[:full_name], 'is too short (minimum is 2 characters)'
  end

  test 'should reject full_name over 100 characters' do
    @address.full_name = 'A' * 101
    assert_not @address.valid?
    assert_includes @address.errors[:full_name], 'is too long (maximum is 100 characters)'
  end

  test 'should require line1' do
    @address.line1 = nil
    assert_not @address.valid?
    assert_includes @address.errors[:line1], "can't be blank"
  end

  test 'should allow blank line2' do
    @address.line2 = ''
    assert @address.valid?
  end

  test 'should require city' do
    @address.city = nil
    assert_not @address.valid?
    assert_includes @address.errors[:city], "can't be blank"
  end

  test 'should allow blank county' do
    @address.county = ''
    assert @address.valid?
  end

  test 'should require postcode' do
    @address.postcode = nil
    assert_not @address.valid?
    assert_includes @address.errors[:postcode], "can't be blank"
  end

  test 'should require country' do
    @address.country = nil
    assert_not @address.valid?
    assert_includes @address.errors[:country], "can't be blank"
  end

  test 'should validate valid UK postcodes' do
    valid_postcodes = ['SW1A 1AA', 'SW1A1AA', 'M1 1AA', 'EC1A 1BB', 'W1A 0AX', 'B33 8TH', 'CR2 6XH', 'DN55 1PT', 'GIR 0AA']
    valid_postcodes.each do |postcode|
      @address.postcode = postcode
      assert @address.valid?, "#{postcode} should be a valid UK postcode"
    end
  end

  test 'should reject invalid UK postcodes' do
    invalid_postcodes = %w[INVALID 12345 ABC SW1 SW1A1 SW1A1AAA]
    invalid_postcodes.each do |postcode|
      @address.postcode = postcode
      assert_not @address.valid?, "#{postcode} should be an invalid UK postcode"
      assert_includes @address.errors[:postcode], 'is not a valid UK postcode format'
    end
  end

  test 'should allow any postcode format for non-UK countries' do
    @address.country = 'United States'
    @address.postcode = '90210'
    assert @address.valid?
  end

  test 'should allow valid phone formats' do
    valid_phones = ['+44 20 1234 5678', '020 1234 5678', '+1-555-123-4567', nil, '']
    valid_phones.each do |phone|
      @address.phone = phone
      assert @address.valid?, "#{phone.inspect} should be valid"
    end
  end

  test 'should reject invalid phone formats' do
    @address.phone = 'abc-phone'
    assert_not @address.valid?
    assert_includes @address.errors[:phone], 'only allows numbers, spaces, and +/-()'
  end

  test 'make_primary! should set address as primary' do
    non_primary_address = addresses(:work_address)
    assert_not non_primary_address.primary?

    non_primary_address.make_primary!

    assert non_primary_address.reload.primary?
  end

  test 'make_primary! should unset other primary addresses for user' do
    primary_address = addresses(:home_address)
    non_primary_address = addresses(:work_address)

    assert primary_address.primary?
    assert_not non_primary_address.primary?

    non_primary_address.make_primary!

    assert_not primary_address.reload.primary?
    assert non_primary_address.reload.primary?
  end

  test 'ensure_single_primary should unset other primary when saving new primary' do
    primary_address = addresses(:home_address)
    non_primary_address = addresses(:work_address)

    assert primary_address.primary?
    non_primary_address.update!(primary: true)

    assert_not primary_address.reload.primary?
    assert non_primary_address.reload.primary?
  end

  test 'formatted_address should return complete address string' do
    expected = 'John Smith, 123 High Street, Flat 4, London, Greater London, SW1A 1AA, United Kingdom'
    assert_equal expected, @address.formatted_address
  end

  test 'formatted_address should exclude blank fields' do
    @address.line2 = nil
    @address.county = nil
    expected = 'John Smith, 123 High Street, London, SW1A 1AA, United Kingdom'
    assert_equal expected, @address.formatted_address
  end

  test 'primary_address scope should return only primary addresses' do
    primary_addresses = Address.primary_address
    assert primary_addresses.all?(&:primary?)
  end

  test 'by_label scope should return addresses with matching label' do
    home_addresses = Address.by_label('Home')
    assert(home_addresses.all? { |a| a.label == 'Home' })
  end

  test 'should enable paper_trail auditing' do
    assert Address.respond_to?(:paper_trail)
  end

  test 'should create version on update' do
    @address.update!(line1: 'Updated Address Line')
    assert @address.versions.any?
  end
end
