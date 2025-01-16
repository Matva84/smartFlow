class Employee < ApplicationRecord
  # Associations
  belongs_to :user
  #has_many :leaves, dependent: :destroy
  #has_many :overtimes, dependent: :destroy
  has_and_belongs_to_many :projects
  
  # Validations
  validates :firstname, :lastname, :email, presence: true
  validates :email, uniqueness: true

  # Exemple de méthode pour le nom complet
  def full_name
    "#{firstname} #{lastname}"
  end
end
