# frozen_string_literal: true

# Skip rate limiting in test environment unless explicitly enabled
# This allows most tests to run without rate limiting, but RackAttackTest can enable it
return if Rails.env.test? && !ENV['RACK_ATTACK_ENABLED']

class Rack::Attack
  # Throttle all requests by IP (300 requests per 5 minutes = 1 per second)
  # This protects against general DDoS and brute force attacks
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Throttle admin login attempts by IP
  # Allows 5 attempts per 20 seconds to prevent brute force attacks on admin accounts
  throttle('admin_logins/ip', limit: 5, period: 20.seconds) do |req|
    if req.path == '/admin_users/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle admin login attempts by email
  # Allows 5 attempts per 20 seconds to prevent credential stuffing
  throttle('admin_logins/email', limit: 5, period: 20.seconds) do |req|
    if req.path == '/admin_users/sign_in' && req.post?
      email = req.params.dig('admin_user', 'email')
      email.to_s.downcase.strip.presence
    end
  end

  # Throttle checkout attempts by IP
  # Allows 10 attempts per minute to prevent checkout abuse
  throttle('checkout/ip', limit: 10, period: 1.minute) do |req|
    if req.path == '/checkout' && req.post?
      req.ip
    end
  end

  # Throttle contact form submissions by IP
  # Allows 5 submissions per minute to prevent spam
  throttle('contact/ip', limit: 5, period: 1.minute) do |req|
    if req.path == '/contact' && req.post?
      req.ip
    end
  end

  self.blocklisted_responder = lambda do |_req|
    [429, { 'Content-Type' => 'text/plain' }, ['Too Many Requests. Please try again later.']]
  end

  self.throttled_responder = lambda do |_req|
    [429, { 'Content-Type' => 'text/plain' }, ['Too Many Requests. Please try again later.']]
  end
end
