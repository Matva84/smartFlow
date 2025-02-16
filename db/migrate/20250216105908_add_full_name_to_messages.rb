class AddFullNameToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :full_name, :string
  end
end
