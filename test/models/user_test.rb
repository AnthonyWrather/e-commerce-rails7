# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_one)
  end

  test 'should be valid with all required attributes' do
    assert @user.valid?
  end

  test 'should require full_name' do
    @user.full_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:full_name], "can't be blank"
  end

  test 'should require full_name minimum length of 2' do
    @user.full_name = 'A'
    assert_not @user.valid?
    assert_includes @user.errors[:full_name], 'is too short (minimum is 2 characters)'
  end

  test 'should reject full_name over 100 characters' do
    @user.full_name = 'A' * 101
    assert_not @user.valid?
    assert_includes @user.errors[:full_name], 'is too long (maximum is 100 characters)'
  end

  test 'should require email' do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test 'should require unique email' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], 'has already been taken'
  end

  test 'should validate email format' do
    invalid_emails = ['invalid', 'test@', '@test.com']
    invalid_emails.each do |email|
      @user.email = email
      assert_not @user.valid?, "#{email} should be invalid"
    end
  end

  test 'should allow valid phone formats' do
    valid_phones = ['+44 20 1234 5678', '020 1234 5678', '+1-555-123-4567', '(020) 1234-5678']
    valid_phones.each do |phone|
      @user.phone = phone
      assert @user.valid?, "#{phone} should be valid"
    end
  end

  test 'should reject invalid phone formats' do
    @user.phone = 'abc-phone'
    assert_not @user.valid?
    assert_includes @user.errors[:phone], 'only allows numbers, spaces, and +/-()'
  end

  test 'should allow blank phone' do
    @user.phone = ''
    assert @user.valid?
  end

  test 'display_name should return full_name when present' do
    assert_equal 'John Smith', @user.display_name
  end

  test 'display_name should return email prefix when full_name blank' do
    user = User.new(email: 'test@example.com', full_name: '')
    assert_equal 'test', user.display_name
  end

  test 'should have many carts' do
    assert_respond_to @user, :carts
  end

  test 'should have many addresses' do
    assert_respond_to @user, :addresses
  end

  test 'should destroy addresses when destroyed' do
    user = users(:user_one)
    addresses_count = user.addresses.count
    assert addresses_count.positive?

    assert_difference('Address.count', -addresses_count) do
      user.destroy
    end
  end

  test 'should nullify carts when destroyed' do
    user = users(:user_one)
    cart = Cart.create!(session_token: SecureRandom.uuid, user: user)

    user.destroy
    cart.reload

    assert_nil cart.user_id
  end

  test 'should enable paper_trail auditing' do
    assert User.respond_to?(:paper_trail)
  end

  test 'should create version on update' do
    @user.update!(full_name: 'Updated Name')
    assert @user.versions.any?
  end

  test 'should have confirmable module' do
    assert @user.respond_to?(:confirmed?)
    assert @user.respond_to?(:confirm)
  end

  test 'should have recoverable module' do
    assert @user.respond_to?(:send_reset_password_instructions)
    assert @user.respond_to?(:reset_password)
  end

  test 'should have rememberable module' do
    assert @user.respond_to?(:remember_me!)
    assert @user.respond_to?(:forget_me!)
  end
end
