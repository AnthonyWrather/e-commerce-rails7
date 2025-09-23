# frozen_string_literal: true

class AddShippingIdAndDescriptionToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :shipping_id, :string
    add_column :orders, :shipping_description, :string
  end
end
