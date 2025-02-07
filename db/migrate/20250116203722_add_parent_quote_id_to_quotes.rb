class AddParentQuoteIdToQuotes < ActiveRecord::Migration[8.0]
  def change
    add_column :quotes, :parent_quote_id, :integer
    add_index :quotes, :parent_quote_id
  end
end
