# frozen_string_literal: true

class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.references :product, null: false, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.references :stock, null: true, foreign_key: { on_delete: :cascade, on_update: :cascade }
      t.string :size
      t.integer :quantity, null: false
      t.integer :price, null: false

      t.timestamps
    end
    add_index :cart_items, %i[cart_id product_id size], unique: true
  end
end
