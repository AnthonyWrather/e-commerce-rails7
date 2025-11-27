# frozen_string_literal: true

class RevertShippingDimensionFields < ActiveRecord::Migration[7.1]
  def change
    # Revert column names in products table back to original names
    rename_column :products, :shipping_weight, :weight
    rename_column :products, :shipping_height, :height
    rename_column :products, :shipping_length, :length
    rename_column :products, :shipping_width, :width

    # Revert column names in stocks table back to original names
    rename_column :stocks, :shipping_weight, :weight
    rename_column :stocks, :shipping_height, :height
    rename_column :stocks, :shipping_length, :length
    rename_column :stocks, :shipping_width, :width
  end
end
