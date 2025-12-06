# frozen_string_literal: true

require 'test_helper'

class EnvironmentsTest < ActiveSupport::TestCase
  test 'production environment has action_mailer default_url_options configured' do
    # This test verifies the fix for HoneyBadger issue:
    # ArgumentError: Missing host to link to! in Users::RegistrationsController#create
    #
    # The issue occurs because Devise's :confirmable module requires default_url_options
    # to generate confirmation URLs in emails.
    #
    # We verify that production.rb has:
    # config.action_mailer.default_url_options = { host: 'shop.cariana.tech', protocol: 'https' }

    production_rb = File.read(Rails.root.join('config/environments/production.rb'))

    assert_match(/config\.action_mailer\.default_url_options/, production_rb,
                 'Production environment must have action_mailer.default_url_options configured')
    assert_match(/host.*:.*['"]shop\.cariana\.tech['"]/, production_rb,
                 'Production mailer host must be set to shop.cariana.tech')
    assert_match(/protocol.*:.*['"]https['"]/, production_rb,
                 'Production mailer protocol must be set to https')
  end

  test 'development environment has action_mailer default_url_options configured' do
    development_rb = File.read(Rails.root.join('config/environments/development.rb'))

    assert_match(/config\.action_mailer\.default_url_options/, development_rb,
                 'Development environment must have action_mailer.default_url_options configured')
  end

  test 'test environment has action_mailer default_url_options configured' do
    test_rb = File.read(Rails.root.join('config/environments/test.rb'))

    assert_match(/config\.action_mailer\.default_url_options/, test_rb,
                 'Test environment must have action_mailer.default_url_options configured')
  end
end
