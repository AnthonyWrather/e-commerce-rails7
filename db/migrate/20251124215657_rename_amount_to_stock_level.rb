# frozen_string_literal: true

class RenameAmountToStockLevel < ActiveRecord::Migration[7.1]
  def change
    rename_column :products, :amount, :stock_level
    rename_column :stocks, :amount, :stock_level

    # Only rename in backup tables if the column exists
    if column_exists?(:products_backup, :amount)
      rename_column :products_backup, :amount, :stock_level
    end

    return unless column_exists?(:stocks_backup, :amount)

    rename_column :stocks_backup, :amount, :stock_level
  end
end
