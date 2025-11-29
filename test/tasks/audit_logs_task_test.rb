# frozen_string_literal: true

require 'test_helper'

class AuditLogsTaskTest < ActiveSupport::TestCase
  test 'cleanup task removes old audit logs' do
    product = products(:product_one)
    product.update!(name: 'Test Change')
    recent_version = product.versions.last

    old_version = PaperTrail::Version.create!(
      item_type: 'Product',
      item_id: product.id,
      event: 'update',
      created_at: 100.days.ago
    )

    assert_includes PaperTrail::Version.all, old_version
    assert_includes PaperTrail::Version.all, recent_version

    Rails.application.load_tasks
    Rake::Task['audit_logs:cleanup'].reenable
    Rake::Task['audit_logs:cleanup'].invoke

    refute_includes PaperTrail::Version.all, old_version
    assert_includes PaperTrail::Version.all, recent_version
  end
end
