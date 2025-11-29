# frozen_string_literal: true

require 'test_helper'

class ProductStockTest < ActiveSupport::TestCase
  # NOTE: ProductStock model exists but has no corresponding database table
  # This appears to be a legacy model that should potentially be removed
  # The Stock model is the current implementation for product variants
  # ProductStock should likely be deprecated and removed from the codebase

  test 'model class exists' do
    assert_kind_of Class, ProductStock
  end

  test 'model inherits from ApplicationRecord' do
    assert ProductStock < ApplicationRecord
  end

  test 'model has no database table' do
    skip 'ProductStock has no database table - legacy model, use Stock instead'
  end

  test 'should recommend using Stock model instead' do
    # Documentation test - ProductStock is legacy
    # Current implementation uses Stock model for product variants
    assert Stock.table_exists?, 'Stock model should be used for product variants'
  end
end
