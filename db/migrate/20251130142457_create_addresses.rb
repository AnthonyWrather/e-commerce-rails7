# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :label, null: false, default: 'Home'
      t.string :full_name, null: false
      t.string :line1, null: false
      t.string :line2
      t.string :city, null: false
      t.string :county
      t.string :postcode, null: false
      t.string :country, null: false, default: 'United Kingdom'
      t.string :phone
      t.boolean :primary, null: false, default: false

      t.timestamps
    end

    add_index :addresses, %i[user_id primary], name: 'index_addresses_on_user_id_and_primary'
    add_index :addresses, :postcode
  end
end
