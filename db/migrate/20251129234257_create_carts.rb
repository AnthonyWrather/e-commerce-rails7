# frozen_string_literal: true

class CreateCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :carts do |t|
      t.string :session_token, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end
    add_index :carts, :session_token, unique: true
    add_index :carts, :expires_at
  end
end
