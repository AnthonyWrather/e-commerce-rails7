# frozen_string_literal: true

class AddAmountToProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :amount, :integer
  end
end
