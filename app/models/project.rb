class Project < ApplicationRecord
  belongs_to :client
  has_and_belongs_to_many :employees
  has_many :quotes, dependent: :destroy

  # Validations
  validates :name, :description, :address, :start_at, :end_at, presence: true
  #validates :totalbudget, presence: true
  #validates :totalbudget, :human_cost, :material_cost, :customer_budget, :total_expenses, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  #validates :employees, presence: true

  # Méthode pour calculer la progression
  def calculate_progression
    return 0 if totalbudget.zero?

    ((human_cost + material_cost) / totalbudget * 100).to_i
  end
end
