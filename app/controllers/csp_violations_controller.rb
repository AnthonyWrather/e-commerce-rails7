# frozen_string_literal: true

class CspViolationsController < ApplicationController
  # Skip CSRF protection for CSP violation reports from browsers.
  # This is safe because:
  # 1. Browsers send CSP reports automatically without user interaction
  # 2. CSP reports cannot include CSRF tokens by design
  # 3. This endpoint only logs violations - no state-changing operations
  # See: https://www.w3.org/TR/CSP3/#reporting
  skip_before_action :verify_authenticity_token, only: [:create]
  # Skip other before_actions that might interfere with the endpoint
  skip_before_action :set_honeybadger_context, only: [:create]
  skip_before_action :set_paper_trail_whodunnit, only: [:create]
  skip_before_action :set_honeybadger_user_context, only: [:create]

  def create
    report = parse_csp_report

    if report.present?
      log_violation(report)
      notify_error_tracking(report)
    end

    head :no_content
  end

  private

  def parse_csp_report
    return nil if request.body.blank?

    body = request.body.read
    return nil if body.blank?

    json = JSON.parse(body)
    json['csp-report'] || json
  rescue JSON::ParserError
    Rails.logger.warn('[CSP] Invalid JSON in violation report')
    nil
  end

  def log_violation(report)
    Rails.logger.warn(
      '[CSP Violation] ' \
      "blocked-uri: #{report['blocked-uri']} | " \
      "violated-directive: #{report['violated-directive']} | " \
      "document-uri: #{report['document-uri']} | " \
      "source-file: #{report['source-file']} | " \
      "line-number: #{report['line-number']}"
    )
  end

  def notify_error_tracking(report)
    return unless defined?(Honeybadger)

    Honeybadger.notify(
      error_class: 'CSPViolation',
      error_message: "CSP violation: #{report['violated-directive']}",
      context: {
        blocked_uri: report['blocked-uri'],
        violated_directive: report['violated-directive'],
        document_uri: report['document-uri'],
        source_file: report['source-file'],
        line_number: report['line-number'],
        original_policy: report['original-policy']
      }
    )
  end
end
