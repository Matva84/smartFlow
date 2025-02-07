class AddOvertimeHoursToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :overtime_hours, :decimal
  end
end
