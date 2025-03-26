class RenameTotalToTotalHtAndAddTotalTtcToQuotes < ActiveRecord::Migration[8.0]
  def change
    rename_column :quotes, :total, :total_ht
    add_column :quotes, :total_ttc, :decimal
  end
end
