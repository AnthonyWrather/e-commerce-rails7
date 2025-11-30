# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.string :subject
      t.datetime :last_message_at

      t.timestamps
    end

    add_index :conversations, :status
    add_index :conversations, :last_message_at
    add_index :conversations, %i[user_id status]
  end
end
