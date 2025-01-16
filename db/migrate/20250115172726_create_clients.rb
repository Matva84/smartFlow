class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :firstname
      t.string :lastname
      t.string :address
      t.string :phone
      t.string :email
      t.string :rib

      t.timestamps
    end
  end
end
