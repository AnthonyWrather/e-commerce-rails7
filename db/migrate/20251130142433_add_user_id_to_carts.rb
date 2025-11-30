# frozen_string_literal: true

class AddUserIdToCarts < ActiveRecord::Migration[7.1]
  def change
    add_reference :carts, :user, null: true, foreign_key: { on_delete: :nullify }
    add_index :carts, %i[user_id expires_at], name: 'index_carts_on_user_id_and_expires_at'
  end
end
