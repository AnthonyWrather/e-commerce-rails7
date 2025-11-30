# frozen_string_literal: true

class CreateConversationParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :admin_user, null: false, foreign_key: true
      t.datetime :last_read_at
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :conversation_participants, %i[conversation_id admin_user_id],
              unique: true, name: 'index_participants_on_conversation_and_admin'
  end
end
