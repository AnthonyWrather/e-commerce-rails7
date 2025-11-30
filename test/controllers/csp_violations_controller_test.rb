# frozen_string_literal: true

require 'test_helper'

class CspViolationsControllerTest < ActionDispatch::IntegrationTest
  test 'accepts CSP violation report' do
    csp_report = {
      'csp-report' => {
        'blocked-uri' => 'https://evil.com/script.js',
        'violated-directive' => 'script-src',
        'document-uri' => 'https://example.com/page',
        'source-file' => 'https://example.com/page',
        'line-number' => 42
      }
    }

    post csp_violations_url,
         params: csp_report.to_json,
         headers: { 'Content-Type' => 'application/csp-report' }

    assert_response :no_content
  end

  test 'handles empty request body' do
    post csp_violations_url,
         params: '',
         headers: { 'Content-Type' => 'application/csp-report' }

    assert_response :no_content
  end

  test 'handles invalid JSON gracefully' do
    post csp_violations_url,
         params: 'invalid json',
         headers: { 'Content-Type' => 'application/csp-report' }

    assert_response :no_content
  end

  test 'handles report without csp-report wrapper' do
    csp_report = {
      'blocked-uri' => 'https://evil.com/script.js',
      'violated-directive' => 'script-src',
      'document-uri' => 'https://example.com/page'
    }

    post csp_violations_url,
         params: csp_report.to_json,
         headers: { 'Content-Type' => 'application/json' }

    assert_response :no_content
  end

  test 'does not require CSRF token' do
    csp_report = {
      'csp-report' => {
        'blocked-uri' => 'https://evil.com/script.js',
        'violated-directive' => 'script-src'
      }
    }

    # This should not raise ActionController::InvalidAuthenticityToken
    post csp_violations_url,
         params: csp_report.to_json,
         headers: { 'Content-Type' => 'application/csp-report' }

    assert_response :no_content
  end

  test 'logs CSP violations' do
    csp_report = {
      'csp-report' => {
        'blocked-uri' => 'https://malicious.com/tracker.js',
        'violated-directive' => 'script-src',
        'document-uri' => 'https://example.com/checkout',
        'source-file' => 'https://example.com/checkout',
        'line-number' => 100
      }
    }

    # Test passes if no exception is raised during logging
    post csp_violations_url,
         params: csp_report.to_json,
         headers: { 'Content-Type' => 'application/csp-report' }

    assert_response :no_content
  end
end
