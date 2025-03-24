class AddMarginToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :margin, :decimal
  end
end
