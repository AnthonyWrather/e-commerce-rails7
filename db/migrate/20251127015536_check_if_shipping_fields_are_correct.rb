# frozen_string_literal: true

class CheckIfShippingFieldsAreCorrect < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:products, :weight)
      rename_column :products, :weight, :shipping_weight
    end

    if column_exists?(:products, :length)
      rename_column :products, :length, :shipping_length
    end

    if column_exists?(:products, :width)
      rename_column :products, :width, :shipping_width
    end

    if column_exists?(:products, :height)
      rename_column :products, :height, :shipping_height
    end

    if column_exists?(:stocks, :weight)
      rename_column :stocks, :weight, :shipping_weight
    end

    if column_exists?(:stocks, :length)
      rename_column :stocks, :length, :shipping_length
    end

    if column_exists?(:stocks, :width)
      rename_column :stocks, :width, :shipping_width
    end

    return unless column_exists?(:stocks, :height)

    rename_column :stocks, :height, :shipping_height
  end
end
