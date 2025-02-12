class AddValueTypeToSettings < ActiveRecord::Migration[6.0]
  def change
    add_column :settings, :value_type, :string, default: "string", null: false
  end
end
