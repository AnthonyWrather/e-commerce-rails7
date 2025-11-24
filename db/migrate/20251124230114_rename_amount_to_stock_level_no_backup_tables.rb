# frozen_string_literal: true

class RenameAmountToStockLevelNoBackupTables < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :amount, :stock_level
    rename_column :stocks, :amount, :stock_level
  end
end
