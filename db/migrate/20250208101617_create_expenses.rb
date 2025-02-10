class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :amount
      t.date :date
      t.text :description
      t.string :status
      t.string :image
      t.boolean :fixed

      t.timestamps
    end
  end
end
