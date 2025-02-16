class ChangeEmployeeIdNullOnMessages < ActiveRecord::Migration[6.1]
  def change
    change_column_null :messages, :employee_id, true
  end
end
