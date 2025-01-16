class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :firstname
      t.string :lastname
      t.string :address
      t.string :phone
      t.string :email
      t.string :group
      t.string :position
      t.float :hoursalary
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
