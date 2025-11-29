# frozen_string_literal: true

# Start SimpleCov before loading Rails
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Services', 'app/services'

  track_files '{app,lib}/**/*.rb'

  # Set minimum coverage threshold (overall only - per-file disabled for now)
  minimum_coverage 40
  # minimum_coverage_by_file 60  # Disabled - many untested files need coverage improvements
end

ENV['RAILS_ENV'] ||= 'test'
# Ensure Rack::Attack is disabled by default in tests
ENV.delete('RACK_ATTACK_ENABLED')

require_relative '../config/environment'
require 'rails/test_help'

# Load support files
Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

module ActiveSupport
  class TestCase
    # Disable parallel testing to avoid foreign key violations
    # when database user lacks superuser privileges
    # parallelize(workers: :number_of_processors)

    # Setup fixtures in dependency order to avoid foreign key violations
    # when database user lacks superuser privileges
    fixtures :admin_users, :categories, :products, :stocks, :orders, :order_products

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include StripeTestHelpers
end
