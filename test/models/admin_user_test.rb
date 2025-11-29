# frozen_string_literal: true

require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  setup do
    @admin_user = admin_users(:admin_user_one)
  end

  # Validation Tests

  test 'should be valid with valid attributes' do
    assert @admin_user.valid?
  end

  test 'should require email' do
    @admin_user.email = nil
    assert_not @admin_user.valid?
    assert_includes @admin_user.errors[:email], "can't be blank"
  end

  test 'should require email to not be empty string' do
    @admin_user.email = ''
    assert_not @admin_user.valid?
    assert_includes @admin_user.errors[:email], "can't be blank"
  end

  test 'should validate email format' do
    invalid_emails = ['invalid', 'invalid@', '@example.com']
    invalid_emails.each do |invalid_email|
      @admin_user.email = invalid_email
      assert_not @admin_user.valid?, "#{invalid_email} should be invalid"
    end
  end

  test 'should accept valid email formats' do
    valid_emails = ['user@example.com', 'USER@foo.COM', 'A_US-ER@foo.bar.org', 'first.last@foo.jp', 'alice+bob@baz.cn']
    valid_emails.each do |valid_email|
      @admin_user.email = valid_email
      assert @admin_user.valid?, "#{valid_email} should be valid"
    end
  end

  test 'should require unique email' do
    duplicate_admin = @admin_user.dup
    duplicate_admin.email = @admin_user.email.upcase
    @admin_user.save!
    assert_not duplicate_admin.valid?
    assert_includes duplicate_admin.errors[:email], 'has already been taken'
  end

  test 'should save email as lowercase' do
    mixed_case_email = 'AdMiN@ExAmPlE.CoM'
    @admin_user.email = mixed_case_email
    @admin_user.save!
    assert_equal mixed_case_email.downcase, @admin_user.reload.email
  end

  test 'should require password on create' do
    admin = AdminUser.new(email: 'newadmin@example.com')
    assert_not admin.valid?
    assert_includes admin.errors[:password], "can't be blank"
  end

  test 'should not require password on update' do
    @admin_user.email = 'updated@example.com'
    assert @admin_user.valid?
  end

  test 'should require password minimum length' do
    @admin_user.password = @admin_user.password_confirmation = 'a' * 5
    assert_not @admin_user.valid?
    assert_includes @admin_user.errors[:password], 'is too short (minimum is 6 characters)'
  end

  test 'should accept password with minimum length' do
    @admin_user.password = @admin_user.password_confirmation = 'a' * 6
    assert @admin_user.valid?
  end

  test 'should reject password exceeding maximum length' do
    @admin_user.password = @admin_user.password_confirmation = 'a' * 129
    assert_not @admin_user.valid?
    assert_includes @admin_user.errors[:password], 'is too long (maximum is 128 characters)'
  end

  test 'should require password confirmation to match' do
    @admin_user.password = 'password123'
    @admin_user.password_confirmation = 'different'
    assert_not @admin_user.valid?
    assert_includes @admin_user.errors[:password_confirmation], "doesn't match Password"
  end

  # Authentication Tests

  test 'should authenticate with valid password' do
    admin = AdminUser.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
    assert admin.valid_password?('password123')
  end

  test 'should not authenticate with invalid password' do
    admin = AdminUser.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
    assert_not admin.valid_password?('wrongpassword')
  end

  test 'should encrypt password' do
    admin = AdminUser.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
    assert_not_equal 'password123', admin.encrypted_password
    assert admin.encrypted_password.present?
  end

  # Devise Modules Tests

  test 'should have database_authenticatable module' do
    assert AdminUser.devise_modules.include?(:database_authenticatable)
  end

  test 'should have registerable module' do
    assert AdminUser.devise_modules.include?(:registerable)
  end

  test 'should have recoverable module' do
    assert AdminUser.devise_modules.include?(:recoverable)
  end

  test 'should have rememberable module' do
    assert AdminUser.devise_modules.include?(:rememberable)
  end

  test 'should have validatable module' do
    assert AdminUser.devise_modules.include?(:validatable)
  end

  # Password Reset Tests

  test 'should generate reset password token' do
    _, hashed_token = Devise.token_generator.generate(AdminUser, :reset_password_token)
    @admin_user.reset_password_token = hashed_token
    @admin_user.reset_password_sent_at = Time.current
    @admin_user.save!

    assert @admin_user.reset_password_token.present?
  end

  test 'should set reset password sent at when generating token' do
    _, hashed_token = Devise.token_generator.generate(AdminUser, :reset_password_token)
    sent_at = Time.current
    @admin_user.reset_password_token = hashed_token
    @admin_user.reset_password_sent_at = sent_at
    @admin_user.save!

    assert @admin_user.reset_password_sent_at.present?
    assert @admin_user.reset_password_sent_at <= Time.current
  end

  test 'should clear reset password token after password reset' do
    _, hashed_token = Devise.token_generator.generate(AdminUser, :reset_password_token)
    @admin_user.reset_password_token = hashed_token
    @admin_user.reset_password_sent_at = Time.current
    @admin_user.save!

    assert @admin_user.reset_password_token.present?

    @admin_user.reset_password('newpassword123', 'newpassword123')
    assert_nil @admin_user.reset_password_token
    assert_nil @admin_user.reset_password_sent_at
  end

  test 'should set remember_created_at when remembering' do
    @admin_user.remember_me!
    assert @admin_user.remember_created_at.present?
  end

  test 'should clear remember_created_at when forgetting' do
    @admin_user.remember_me!
    assert @admin_user.remember_created_at.present?

    @admin_user.forget_me!
    assert_nil @admin_user.reload.remember_created_at
  end

  # Timestamps Tests

  test 'should set created_at on create' do
    admin = AdminUser.create!(email: 'timestamp@example.com', password: 'password123', password_confirmation: 'password123')
    assert admin.created_at.present?
  end

  test 'should set updated_at on create' do
    admin = AdminUser.create!(email: 'timestamp@example.com', password: 'password123', password_confirmation: 'password123')
    assert admin.updated_at.present?
  end

  test 'should update updated_at on save' do
    original_updated_at = @admin_user.updated_at
    sleep 0.01 # Ensure time difference
    @admin_user.email = 'newemail@example.com'
    @admin_user.save!
    assert @admin_user.updated_at > original_updated_at
  end
end
