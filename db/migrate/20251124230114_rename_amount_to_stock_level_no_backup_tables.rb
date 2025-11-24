# frozen_string_literal: true

class RenameAmountToStockLevelNoBackupTables < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:products, :amount)
      rename_column :products, :amount, :stock_level
    end

    return unless column_exists?(:stocks, :amount)

    rename_column :stocks, :amount, :stock_level
  end
end
