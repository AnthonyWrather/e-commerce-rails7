# frozen_string_literal: true

class AddShippingToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :payment_status, :string
    add_column :orders, :payment_id, :string
    add_column :orders, :shipping_cost, :integer
  end
end
