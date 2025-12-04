# frozen_string_literal: true

require 'test_helper'

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test 'CSP headers are present in response' do
    get root_url

    # In report-only mode, check for Content-Security-Policy-Report-Only header
    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert csp_header.present?, 'CSP header should be present'
  end

  test 'CSP header includes default-src directive' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(/default-src 'self'/, csp_header)
  end

  test 'CSP header allows Stripe JavaScript SDK' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(%r{script-src[^;]*https://js\.stripe\.com}, csp_header)
  end

  test 'CSP header allows Google Analytics' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(%r{script-src[^;]*https://www\.googletagmanager\.com}, csp_header)
    assert_match(%r{script-src[^;]*https://www\.google-analytics\.com}, csp_header)
  end

  test 'CSP header allows Honeybadger' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(%r{script-src[^;]*https://js\.honeybadger\.io}, csp_header)
  end

  test 'CSP header disallows object-src' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(/object-src 'none'/, csp_header)
  end

  test 'CSP header allows Stripe frames for 3D Secure' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(%r{frame-src[^;]*https://js\.stripe\.com}, csp_header)
    assert_match(%r{frame-src[^;]*https://hooks\.stripe\.com}, csp_header)
  end

  test 'CSP header restricts frame-ancestors to self' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(/frame-ancestors 'self'/, csp_header)
  end

  test 'CSP meta tag is present in HTML response' do
    get root_url

    assert_select 'meta[name="csp-nonce"]', true
  end

  test 'CSP header allows inline styles' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    # Either 'unsafe-inline' or nonce should be present for styles
    style_directive_allows_inline = csp_header.match?(/style-src[^;]*'unsafe-inline'/) ||
                                    csp_header.match?(/style-src[^;]*'nonce-/)
    assert style_directive_allows_inline, 'CSP should allow inline styles'
  end

  test 'CSP header allows self for connect-src' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(/connect-src[^;]*'self'/, csp_header)
  end

  test 'CSP header allows Stripe API for connect-src' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    assert_match(%r{connect-src[^;]*https://api\.stripe\.com}, csp_header)
  end

  test 'CSP header allows inline style attributes' do
    get root_url

    csp_header = response.headers['Content-Security-Policy'] ||
                 response.headers['Content-Security-Policy-Report-Only']

    # style-src-attr directive should allow 'unsafe-inline' for style="" attributes
    assert_match(/style-src-attr[^;]*'unsafe-inline'/, csp_header,
                 'CSP should include style-src-attr directive with unsafe-inline to allow style attributes')
  end
end
