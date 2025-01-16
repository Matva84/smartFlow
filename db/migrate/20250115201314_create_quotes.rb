class CreateQuotes < ActiveRecord::Migration[8.0]
  def change
    create_table :quotes do |t|
      t.string :number
      t.string :status
      t.decimal :total
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
