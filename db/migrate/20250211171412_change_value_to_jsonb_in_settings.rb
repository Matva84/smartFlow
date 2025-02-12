class ChangeValueToJsonbInSettings < ActiveRecord::Migration[6.0]
  def change
    change_column :settings, :value, :jsonb, using: 'value::jsonb'
  end
end

