class AddDefaultStatusToQuotes < ActiveRecord::Migration[8.0]
  def change
    change_column_default :quotes, :status, from: nil, to: "creation"
  end
end
