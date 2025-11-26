# frozen_string_literal: true

class RenameShippingDimensionFields < ActiveRecord::Migration[7.1]
  def change
    # Rename columns in products table
    rename_column :products, :weight, :shipping_weight
    rename_column :products, :height, :shipping_height
    rename_column :products, :length, :shipping_length
    rename_column :products, :width, :shipping_width

    # Rename columns in stocks table
    rename_column :stocks, :weight, :shipping_weight
    rename_column :stocks, :height, :shipping_height
    rename_column :stocks, :length, :shipping_length
    rename_column :stocks, :width, :shipping_width
  end
end
