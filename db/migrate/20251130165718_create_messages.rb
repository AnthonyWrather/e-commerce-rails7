# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :sender, polymorphic: true, null: false
      t.text :content, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, %i[conversation_id created_at]
    add_index :messages, %i[sender_type sender_id]
  end
end
