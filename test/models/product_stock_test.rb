# frozen_string_literal: true

require 'test_helper'

class ProductStockTest < ActiveSupport::TestCase
  # NOTE: ProductStock model exists but has no corresponding database table
  # This appears to be a legacy model that should potentially be removed
  # Skipping tests as the table doesn't exist in the database

  test 'model exists but has no database table' do
    skip 'ProductStock has no database table - legacy model'
  end
end
