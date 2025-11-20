# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

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
end
