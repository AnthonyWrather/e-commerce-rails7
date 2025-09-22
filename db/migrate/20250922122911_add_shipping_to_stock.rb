# frozen_string_literal: true

class AddShippingToStock < ActiveRecord::Migration[7.1]
  def change
    add_column :stocks, :weight, :integer
    add_column :stocks, :length, :integer
    add_column :stocks, :width, :integer
    add_column :stocks, :height, :integer
  end
end
