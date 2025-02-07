class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string :event_type
      t.date :start_date
      t.date :end_date
      t.references :employee, null: false, foreign_key: true

      t.timestamps
    end
  end
end
