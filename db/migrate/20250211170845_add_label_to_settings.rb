class AddLabelToSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :settings, :label, :string
  end
end
