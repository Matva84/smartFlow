class ExpensesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, except: [:pending_count2, :global_expenses_by_date] # 🚀 EXCLUSION DE pending_count2
  before_action :set_expense, only: [:edit, :update, :destroy, :approve, :reject]

  def index
    @expenses = @employee.expenses.order(date: :desc)
  end

  def new
    @expense = @employee.expenses.new
  end

  def create
    @expense = @employee.expenses.new(expense_params)
    @expense.status = "en_attente" # Par défaut, les frais sont en attente

    if @expense.save
      redirect_to employee_path(@employee), notice: "Note de frais ajoutée avec succès."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @expense.update(expense_params)
      redirect_to employee_path(@employee), notice: "Note de frais mise à jour."
    else
      render :edit
    end
  end

  def destroy
    @expense.destroy
    redirect_to employee_path(@employee), notice: "Note de frais supprimée."
  end

  def approve
    #Rails.logger.debug "🟢 DEBUG: L'action approve est appelée avec params: #{params.inspect}"

    # Vérifie que set_expense est bien exécuté
    #Rails.logger.debug "🟡 Vérification: @expense avant set_expense = #{@expense.inspect}"

    # Charge directement l'expense
    @expense = Expense.find_by(id: params[:id])

    #Rails.logger.debug "🔍 Après recherche dans la DB: @expense = #{@expense.inspect}"

    if @expense.nil?
      Rails.logger.error "❌ ERREUR: L'expense avec ID=#{params[:id]} n'existe pas."
      redirect_to employees_path, alert: "Erreur : La note de frais spécifiée n'existe pas." and return
    end

    if @expense.update(status: 'approuvé')
      #Rails.logger.info "✅ L'expense ID=#{@expense.id} a été approuvée."
      redirect_to employees_path, notice: "La note de frais a été approuvée."
    else
      Rails.logger.error "❌ Échec de l'approbation pour l'expense ID=#{@expense.id}."
      redirect_to employees_path, alert: "Impossible d'approuver la note de frais."
    end
  end

  def pending_count2
    pending_expenses_count = Expense.where(status: 'en_attente').count
    render json: { pending_expenses_count: pending_expenses_count }
  end

  def global_expenses_by_date
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today.beginning_of_year
    end_date = Date.today

    # Liste des débuts de mois entre start_date et end_date
    months = (start_date..end_date).map { |d| Date.new(d.year, d.month, 1) }.uniq

    # Récupérer les dépenses approuvées depuis start_date
    expenses_by_employee = Expense.includes(:employee)
                                  .where("date >= ?", start_date)
                                  .where(status: 'approuvé')
                                  .group_by(&:employee)
                                  .transform_values do |expenses|
                                    expenses.group_by { |e| Date.new(e.date.year, e.date.month, 1) }
                                            .transform_values { |e| e.sum(&:amount) }
                                  end

    # Pour chaque employé, construire un tableau des montants pour chaque mois et calculer la somme totale
    formatted_expenses = {}
    totals = {}
    expenses_by_employee.each do |employee, expenses|
      employee_name = employee.full_name
      amounts = months.map { |m| expenses[m] || 0 }
      formatted_expenses[employee_name] = amounts
      totals[employee_name] = amounts.sum
    end

    # Préparer les labels de l'axe des x (ex: "Jan 2023", "Fév 2023", etc.)
    labels = months.map { |m| m.strftime("%b %Y") }

    render json: { labels: labels, data: formatted_expenses, totals: totals }
  end



  def reject
    if @expense.update(status: 'refusé')
      redirect_to employees_path, notice: "La note de frais a été refusée."
    else
      redirect_to employees_path, alert: "Impossible de refuser la note de frais."
    end
  end

  private

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def set_expense
    @expense = @employee.expenses.find_by(id: params[:id])

    if @expense.nil?
      Rails.logger.error "❌ ERREUR: Impossible de trouver l'expense avec ID=#{params[:id]} pour l'employé ID=#{params[:employee_id]}"
      redirect_to employees_path, alert: "Erreur : La note de frais spécifiée n'existe pas."
    end
  end



  def expense_params
    params.require(:expense).permit(:amount, :date, :description, :image, :status, :fixed)
  end
end
