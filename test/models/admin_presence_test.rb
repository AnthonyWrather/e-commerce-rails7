# frozen_string_literal: true

require 'test_helper'

class AdminPresenceTest < ActiveSupport::TestCase
  def setup
    @presence = admin_presences(:admin_presence_one)
    @admin_user = admin_users(:admin_user_one)
    @admin_user_two = admin_users(:admin_user_two)
  end

  # Validations
  test 'should be valid with all required attributes' do
    assert @presence.valid?
  end

  test 'should require unique admin_user_id' do
    duplicate = AdminPresence.new(
      admin_user: @admin_user,
      status: 'online'
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:admin_user_id], 'has already been taken'
  end

  test 'should require valid status' do
    @presence.status = 'invalid'
    assert_not @presence.valid?
    assert_includes @presence.errors[:status], 'is not included in the list'
  end

  test 'should accept status online' do
    @presence.status = 'online'
    assert @presence.valid?
  end

  test 'should accept status away' do
    @presence.status = 'away'
    assert @presence.valid?
  end

  test 'should accept status offline' do
    @presence.status = 'offline'
    assert @presence.valid?
  end

  # Associations
  test 'should belong to admin_user' do
    assert_respond_to @presence, :admin_user
    assert_equal @admin_user, @presence.admin_user
  end

  # Scopes
  test 'online scope should return only online presences' do
    online_presences = AdminPresence.online
    assert(online_presences.all? { |p| p.status == 'online' })
  end

  test 'available scope should return online and away presences' do
    # Set one presence to away
    @presence.update!(status: 'away')

    available = AdminPresence.available
    assert(available.all? { |p| %w[online away].include?(p.status) })
  end

  # Class methods
  test 'mark_online should create presence if not exists' do
    # Use a new admin user without presence
    new_admin = AdminUser.create!(
      email: 'new_admin@example.com',
      password: 'password123'
    )

    assert_difference('AdminPresence.count', 1) do
      AdminPresence.mark_online(new_admin)
    end

    presence = AdminPresence.find_by(admin_user: new_admin)
    assert_equal 'online', presence.status
    assert_not_nil presence.last_seen_at
  end

  test 'mark_online should update existing presence' do
    original_seen_at = @presence.last_seen_at
    sleep 0.1
    AdminPresence.mark_online(@admin_user)
    @presence.reload

    assert_equal 'online', @presence.status
    assert @presence.last_seen_at > original_seen_at
  end

  test 'mark_offline should update status to offline' do
    @presence.update!(status: 'online')
    AdminPresence.mark_offline(@admin_user)
    @presence.reload

    assert_equal 'offline', @presence.status
  end

  test 'mark_offline should update last_seen_at' do
    original_seen_at = @presence.last_seen_at
    sleep 0.1
    AdminPresence.mark_offline(@admin_user)
    @presence.reload

    assert @presence.last_seen_at > original_seen_at
  end

  test 'mark_offline should return nil if presence not found' do
    new_admin = AdminUser.create!(
      email: 'no_presence@example.com',
      password: 'password123'
    )

    result = AdminPresence.mark_offline(new_admin)
    assert_nil result
  end

  # Default values
  test 'should default status to offline' do
    presence = AdminPresence.new(admin_user: AdminUser.new)
    # Database default is 'offline', but model may not reflect until save
    assert_equal 'offline', presence.status
  end
end
