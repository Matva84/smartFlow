class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.string :address
      t.float :latitude
      t.float :longitude
      t.date :start_at
      t.date :end_at
      t.date :initial_start_at
      t.date :initial_end_at
      t.float :totalbudget
      t.integer :progression
      t.float :human_cost
      t.float :material_cost
      t.float :customer_budget
      t.float :total_expenses
      t.references :client, null: false, foreign_key: true

      t.timestamps
    end
  end
end
