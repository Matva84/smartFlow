class Client < ApplicationRecord
  validates :firstname, :lastname, :email, :phone, presence: true
  validates :email, uniqueness: true
  has_many :messages, as: :messageable, dependent: :destroy
end
