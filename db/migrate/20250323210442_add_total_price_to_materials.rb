class AddTotalPriceToMaterials < ActiveRecord::Migration[8.0]
  def change
    add_column :materials, :total_price, :decimal
  end
end
