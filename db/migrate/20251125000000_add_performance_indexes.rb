# frozen_string_literal: true

class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # Orders table indexes for filtering and sorting
    add_index :orders, :fulfilled unless index_exists?(:orders, :fulfilled)
    add_index :orders, :created_at unless index_exists?(:orders, :created_at)
    add_index :orders, %i[fulfilled created_at] unless index_exists?(:orders, %i[fulfilled created_at])

    # Products table indexes for filtering and searching
    add_index :products, :active unless index_exists?(:products, :active)
    add_index :products, :price unless index_exists?(:products, :price)
    add_index :products, :name unless index_exists?(:products, :name)

    # Composite index for common query pattern (active products with price filtering)
    add_index :products, %i[active price category_id] unless index_exists?(:products, %i[active price category_id])
  end
end
