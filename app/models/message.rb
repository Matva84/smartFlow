class Message < ApplicationRecord
  belongs_to :user
  belongs_to :messageable, polymorphic: true

  # Méthode pratique pour savoir si un message est lu
  def read?
    read_at.present?
  end
  
end
