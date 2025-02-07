class AddStatusToEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :events, :status, :string, default: 'en_attente'
  end
end
