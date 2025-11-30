# frozen_string_literal: true

class AddTwoFactorFieldsToAdminUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_users, :otp_secret, :string
    add_column :admin_users, :consumed_timestep, :integer
    add_column :admin_users, :otp_required_for_login, :boolean, default: false, null: false
    add_column :admin_users, :otp_backup_codes, :text
  end
end
