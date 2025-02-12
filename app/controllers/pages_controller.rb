class PagesController < ApplicationController
  before_action :authenticate_user!#, except: [:home]

  def home
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_year
    @start_date = start_date.strftime('%Y-%m-%d')  # Format requis pour <input type="date">
    end_date = Date.today.end_of_year

    @expenses_by_employee = {}

    Employee.includes(:expenses).each do |employee|
      monthly_expenses = Array.new(12, 0)

      employee.expenses.where(status: "approuvé", date: start_date..end_date).each do |expense|
        month_index = expense.date.month - 1
        monthly_expenses[month_index] += expense.amount.to_f
      end

      @expenses_by_employee[employee.full_name] = monthly_expenses
    end

    Rails.logger.debug "🔍 Données envoyées à la vue : #{@expenses_by_employee.inspect}"

    # Vérifie que la variable n'est pas vide
    if @expenses_by_employee.empty?
      Rails.logger.error "❌ ERREUR : Aucune donnée de notes de frais trouvée pour les employés."
    end

    puts "🔍 JSON envoyé à la vue : #{@expenses_by_employee.to_json}"
  end



    def expenses_by_employee
      start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_year
      end_date = Date.today.end_of_year

      expenses_by_employee = {}

      Employee.includes(:expenses).each do |employee|
        # Initialise un tableau avec 12 mois à zéro
        monthly_expenses = Array.new(12, 0)

        # Récupère les dépenses approuvées de l'employé entre start_date et end_date
        employee.expenses.where(status: "approuvé", date: start_date..end_date).each do |expense|
          month_index = expense.date.month - 1
          monthly_expenses[month_index] += expense.amount.to_f
        end

        # Associe l'employé à ses dépenses mensuelles
        expenses_by_employee[employee.full_name] = monthly_expenses
      end

      render json: { expenses: expenses_by_employee, year: start_date.year }
    end


  def about
    # Nécessite une authentification
  end
end
