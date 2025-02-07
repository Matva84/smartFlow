class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :category
      t.text :description
      t.integer :duration
      t.integer :nb_people
      t.decimal :hourly_cost
      t.decimal :human_margin
      t.decimal :human_total_cost
      t.string :material
      t.decimal :unit_price_ht
      t.integer :quantity
      t.decimal :total_price_ht
      t.decimal :material_margin
      t.decimal :vat_value
      t.decimal :material_cost
      t.decimal :total_cumulative
      t.decimal :total_margin
      t.references :quote, null: false, foreign_key: true

      t.timestamps
    end
  end
end
