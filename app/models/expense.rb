class Expense < ApplicationRecord
  belongs_to :employee
  has_one_attached :image

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: ["en_attente", "approuvé", "refusé"] }
  validates :category, presence: true

  scope :fixed, -> { where(fixed_expense: true) }

  def self.generate_monthly_fixed_expenses
    fixed.each do |expense|
      Expense.create!(
        employee: expense.employee,
        amount: expense.amount,
        date: Date.today.beginning_of_month, # Début du mois
        description: expense.description,
        status: 'en attente', # Toujours en attente avant validation
        fixed_expense: true,
        category: 'Non classée'
      )
    end
  end
end
