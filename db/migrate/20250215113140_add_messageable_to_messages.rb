class AddMessageableToMessages < ActiveRecord::Migration[6.1]
  def change
    add_reference :messages, :messageable, polymorphic: true, index: true
  end
end
