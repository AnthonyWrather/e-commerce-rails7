# frozen_string_literal: true

class AddFiberglassFieldsToProductsAndStocks < ActiveRecord::Migration[7.1]
  def change
    # Add fields to products table
    add_column :products, :fiberglass_reinforcement, :boolean, default: false, null: false
    add_column :products, :min_resin_per_m2, :integer, default: 0, null: false
    add_column :products, :max_resin_per_m2, :integer, default: 0, null: false
    add_column :products, :avg_resin_per_m2, :integer, default: 0, null: false

    # Add fields to stocks table
    add_column :stocks, :fiberglass_reinforcement, :boolean, default: false, null: false
    add_column :stocks, :min_resin_per_m2, :integer, default: 0, null: false
    add_column :stocks, :max_resin_per_m2, :integer, default: 0, null: false
    add_column :stocks, :avg_resin_per_m2, :integer, default: 0, null: false
  end
end
