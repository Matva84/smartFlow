class AddTotalLeavesTakenToEmployees < ActiveRecord::Migration[6.0]
  def change
    add_column :employees, :total_leaves_taken, :float, default: 0
  end
end
