class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.string :name
      t.decimal :unit_price
      t.decimal :margin
      t.integer :quantity
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
