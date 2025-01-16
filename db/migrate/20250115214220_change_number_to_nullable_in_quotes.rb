class ChangeNumberToNullableInQuotes < ActiveRecord::Migration[7.0]
  def change
    change_column_null :quotes, :number, true
  end
end
