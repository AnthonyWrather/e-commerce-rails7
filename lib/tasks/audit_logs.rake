# frozen_string_literal: true

namespace :audit_logs do
  desc 'Delete audit log entries older than 90 days'
  task cleanup: :environment do
    retention_days = ENV.fetch('AUDIT_LOG_RETENTION_DAYS', 90).to_i
    cutoff_date = retention_days.days.ago

    deleted_count = PaperTrail::Version.where('created_at < ?', cutoff_date).delete_all

    Rails.logger.info "[AuditLogs] Deleted #{deleted_count} audit log entries older than #{retention_days} days"
    puts "Deleted #{deleted_count} audit log entries older than #{retention_days} days"
  end
end
