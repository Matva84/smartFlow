class AddLeaveDaysCountToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :leave_days_count, :float, default: 0
  end
end
