class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_one :employee, dependent: :destroy

  # Validations
  validates :role, presence: true, inclusion: { in: %w[admin employee customer] } # Exemple de rôles
end
