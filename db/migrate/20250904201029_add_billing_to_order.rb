# frozen_string_literal: true

class AddBillingToOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :phone, :string
    add_column :orders, :billing_name, :string
    add_column :orders, :billing_address, :string
  end
end
