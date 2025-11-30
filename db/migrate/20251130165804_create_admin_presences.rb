# frozen_string_literal: true

class CreateAdminPresences < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_presences do |t|
      t.references :admin_user, null: false, foreign_key: true, index: { unique: true }
      t.string :status, default: 'offline', null: false
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :admin_presences, :status
    add_index :admin_presences, :last_seen_at
  end
end
