class ExpensesController < ApplicationController
  before_action :set_employee
  before_action :set_expense, only: [:edit, :update, :destroy]

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
    Rails.logger.debug "🟢 DEBUG: L'action approve est appelée avec params: #{params.inspect}"

    # Vérifie que set_expense est bien exécuté
    Rails.logger.debug "🟡 Vérification: @expense avant set_expense = #{@expense.inspect}"

    # Charge directement l'expense
    @expense = Expense.find_by(id: params[:id])

    Rails.logger.debug "🔍 Après recherche dans la DB: @expense = #{@expense.inspect}"

    if @expense.nil?
      Rails.logger.error "❌ ERREUR: L'expense avec ID=#{params[:id]} n'existe pas."
      redirect_to employees_path, alert: "Erreur : La note de frais spécifiée n'existe pas." and return
    end

    if @expense.update(status: 'approuvé')
      Rails.logger.info "✅ L'expense ID=#{@expense.id} a été approuvée."
      redirect_to employees_path, notice: "La note de frais a été approuvée."
    else
      Rails.logger.error "❌ Échec de l'approbation pour l'expense ID=#{@expense.id}."
      redirect_to employees_path, alert: "Impossible d'approuver la note de frais."
    end
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
