# frozen_string_literal: true

class AddNameToOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :name, :string
  end
end
