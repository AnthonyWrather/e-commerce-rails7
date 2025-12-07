# frozen_string_literal: true

require 'test_helper'

class SemanticLoggerConfigurationTest < ActiveSupport::TestCase
  test 'semantic_logger initializer exists' do
    initializer_path = Rails.root.join('config/initializers/semantic_logger.rb')
    assert File.exist?(initializer_path), 'semantic_logger initializer must exist'
  end

  test 'semantic_logger initializer configures application name' do
    initializer_content = File.read(Rails.root.join('config/initializers/semantic_logger.rb'))
    assert_match(/SemanticLogger\.application\s*=\s*['"]e-commerce-rails7['"]/, initializer_content,
                 'SemanticLogger must have application name configured')
  end

  test 'semantic_logger initializer integrates with Honeybadger conditionally' do
    initializer_content = File.read(Rails.root.join('config/initializers/semantic_logger.rb'))

    # Check that Honeybadger integration is configured based on environment
    assert_match(/honeybadger_enabled\s*=/, initializer_content,
                 'Must check if Honeybadger is enabled')

    assert_match(/Rails\.env\.production\?/, initializer_content,
                 'Must enable Honeybadger logging in production')

    assert_match(/Rails\.env\.test\?/, initializer_content,
                 'Must enable Honeybadger logging in test')

    assert_match(/ENV\['HONEYBADGER_ENABLED_IN_DEV'\]/, initializer_content,
                 'Must check HONEYBADGER_ENABLED_IN_DEV for development')

    assert_match(/Honeybadger\.add_breadcrumb/, initializer_content,
                 'Must send logs as Honeybadger breadcrumbs')
  end

  test 'SemanticLogger is configured in test environment' do
    # In test environment, SemanticLogger should be initialized
    assert_respond_to SemanticLogger, :application, 'SemanticLogger should respond to application'
    assert_equal 'e-commerce-rails7', SemanticLogger.application,
                 'SemanticLogger application name should be e-commerce-rails7'
  end

  test 'SemanticLogger has appenders configured' do
    # In test environment, should have at least stdout appender
    assert SemanticLogger.appenders.any?, 'SemanticLogger should have appenders configured'

    # Check for stdout appender
    stdout_appender = SemanticLogger.appenders.find { |a| a.is_a?(SemanticLogger::Appender::IO) }
    assert_not_nil stdout_appender, 'SemanticLogger should have stdout appender'
  end

  test 'production environment uses SemanticLogger' do
    production_rb = File.read(Rails.root.join('config/environments/production.rb'))

    # Should NOT have the old logger configuration
    assert_no_match(/config\.logger\s*=\s*ActiveSupport::Logger\.new/, production_rb,
                    'Production should not use ActiveSupport::Logger directly')

    # Should reference SemanticLogger
    assert_match(/SemanticLogger/, production_rb,
                 'Production should reference SemanticLogger')
  end

  test 'logging a message does not raise an error' do
    # This test ensures that the logging infrastructure is working
    assert_nothing_raised do
      Rails.logger.info 'Test log message for semantic logger'
      Rails.logger.debug 'Test debug message'
      Rails.logger.warn 'Test warning message'
      Rails.logger.error 'Test error message'
    end
  end

  test 'Rails logger responds to semantic logger methods' do
    # SemanticLogger extends Rails logger with additional methods
    assert_respond_to Rails.logger, :info, 'Logger should respond to info'
    assert_respond_to Rails.logger, :debug, 'Logger should respond to debug'
    assert_respond_to Rails.logger, :warn, 'Logger should respond to warn'
    assert_respond_to Rails.logger, :error, 'Logger should respond to error'
  end

  test 'semantic logger configuration respects environment settings' do
    # Test that configuration is environment-aware
    initializer_content = File.read(Rails.root.join('config/initializers/semantic_logger.rb'))

    # Should set default log level from environment variable
    assert_match(/ENV\.fetch\(['"]RAILS_LOG_LEVEL['"]/, initializer_content,
                 'Should read log level from RAILS_LOG_LEVEL environment variable')
  end
end
