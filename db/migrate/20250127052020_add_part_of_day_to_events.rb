class AddPartOfDayToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :part_of_day, :string
  end
end
