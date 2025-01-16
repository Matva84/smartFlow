class Client < ApplicationRecord
  validates :firstname, :lastname, :email, :phone, presence: true
  validates :email, uniqueness: true
end
