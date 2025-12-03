# frozen_string_literal: true

# Skip asset compilation during tests to prevent intermittent hangs
# This affects both Tailwind CSS and JavaScript builds

# Always disable asset builds in test environment
if Rails.env.test?
  # Override test:prepare to prevent gem enhancements from running
  # namespace :test do
  #   task :prepare do
  #     # No-op: Assets should be pre-built
  #   end
  # end

  # Also override the individual build tasks to be no-ops
  # namespace :tailwindcss do
  #   task :build do
  #     puts 'Tailwind build skipped in test environment'
  #   end
  # end

  # namespace :javascript do
  #   task :build do
  #     puts 'JavaScript build skipped in test environment'
  #   end
  # end
end
