class AddDefaultDaysOffToEmployees < ActiveRecord::Migration[6.1]
  def change
    add_column :employees, :default_days_off, :integer, array: true, default: [6, 0]
  end
end
