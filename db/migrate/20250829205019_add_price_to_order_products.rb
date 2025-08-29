# frozen_string_literal: true

class AddPriceToOrderProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :order_products, :price, :integer
  end
end
