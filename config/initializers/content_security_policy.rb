# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Content Security Policy (CSP) Headers
# Implements defense-in-depth against XSS attacks by controlling resource loading.
# See: https://guides.rubyonrails.org/security.html#content-security-policy-header
#
# Policy is configured in report-only mode initially for validation.
# Set CSP_ENFORCE_MODE=true environment variable to enable enforcement.

Rails.application.configure do
  config.content_security_policy do |policy|
    # Default source - fallback for all resource types not explicitly specified
    policy.default_src :self

    # Scripts - allow self, nonces for inline scripts, and trusted external sources
    policy.script_src :self,
                      :unsafe_inline, # Required for Turbo/Stimulus inline handlers
                      'https://js.stripe.com', # Stripe payment SDK
                      'https://www.googletagmanager.com', # Google Tag Manager
                      'https://www.google-analytics.com', # Google Analytics
                      'https://js.honeybadger.io' # Honeybadger error tracking

    # Styles - allow self, nonces for inline styles, and trusted sources
    policy.style_src :self,
                     :unsafe_inline # Required for Tailwind and inline styles

    # Style attributes - allow inline style attributes on elements
    # This is separate from style-src and needed for style="..." attributes
    policy.style_src_attr :unsafe_inline

    # Images - allow self, https, data URIs, and specific sources
    policy.img_src :self,
                   :https,
                   :data,
                   :blob,
                   'https://www.google-analytics.com',
                   'https://www.googletagmanager.com'

    # Fonts - allow self, https, and data URIs
    policy.font_src :self,
                    :https,
                    :data

    # Frames - only allow Stripe for 3D Secure authentication
    policy.frame_src 'https://js.stripe.com',
                     'https://hooks.stripe.com'

    # Connections (XHR, WebSockets, fetch) - allow self and trusted APIs
    policy.connect_src :self,
                       'https://api.stripe.com',         # Stripe API
                       'https://api.honeybadger.io',     # Honeybadger API
                       'https://www.google-analytics.com',
                       'https://*.google-analytics.com',
                       :wss # WebSockets for ActionCable

    # Objects (Flash, Java, etc.) - disable for security
    policy.object_src :none

    # Base URI - restrict to self to prevent base tag hijacking
    policy.base_uri :self

    # Form actions - allow self and Stripe for checkout redirects
    policy.form_action :self,
                       'https://checkout.stripe.com'

    # Frame ancestors - prevent clickjacking by only allowing self
    policy.frame_ancestors :self

    # Violation reporting endpoint
    policy.report_uri '/csp_violations' if Rails.env.production? || ENV['CSP_REPORT_VIOLATIONS']
  end

  # Generate session nonces for permitted inline scripts and styles
  # Uses SecureRandom for cryptographic security when session unavailable
  config.content_security_policy_nonce_generator = lambda { |request|
    request.session.id.to_s.presence || SecureRandom.base64(16)
  }
  config.content_security_policy_nonce_directives = %w[script-src style-src]

  # Report-only mode by default for safe rollout
  # Set CSP_ENFORCE_MODE=true to switch to enforcement
  config.content_security_policy_report_only = !ENV['CSP_ENFORCE_MODE'].present?
end
