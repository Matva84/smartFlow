class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  def index
    @employees = Employee.order(:lastname, :firstname)

    # Initialiser la collection avec tous les employés
    @selected_employees = @employees

    # Appliquer le filtre par groupe si présent
    if params[:group].present?
      @selected_employees = @selected_employees.where(group: params[:group])
    end

    # Appliquer le filtre par poste si présent
    if params[:position].present?
      @selected_employees = @selected_employees.where(position: params[:position])
    end

    # Compter le nombre total d'employés
    @total_employees = Employee.count

    # Compter les employés par groupe et par poste
    @group_counts = Employee.group(:group).count
    @position_counts = Employee.group(:position).count

    #@employees_all = Employee.all
    today = Date.today

    # Vérifier si aujourd'hui est un jour de week-end ou un jour de repos pour chaque employé
    non_working_employees = @employees.select do |employee|
      employee.default_days_off.include?(today.wday) # Vérifie si aujourd'hui est un jour de repos
    end.count

    # Nombre d'employés en télétravail aujourd'hui
    @remote_count = Event.where(event_type: 'télétravail')
                         .where("start_date <= ? AND end_date >= ?", today, today)
                         .count || 0

    # Nombre d'employés en congé aujourd'hui
    @holiday_count = Event.where(event_type: 'congé')
                          .where("start_date <= ? AND end_date >= ?", today, today)
                          .count || 0

    # Nombre d'employés en arrêt maladie aujourd'hui
    @sick_count = Event.where(event_type: 'arrêt_maladie')
                       .where("start_date <= ? AND end_date >= ?", today, today)
                       .count || 0

    # Nombre d'employés sur site = Total - (Télétravail + Congés + Maladie + Jours non travaillés)
    @onsite_count = @employees.size - (@remote_count + @holiday_count + @sick_count + non_working_employees)
  end


  def show
    @employee = Employee.find(params[:id])
    current_year = Date.today.year

    # Initialisation des congés pour l'année en cours
    @current_year_leaves = @employee.events.where(event_type: 'congé', status: 'approuvé', start_date: Date.new(current_year)..Date.new(current_year).end_of_year)

    # Initialisation des jours de télétravail pour l'année en cours
    @current_year_teleworks = @employee.events.where(event_type: 'télétravail', start_date: Date.new(current_year)..Date.new(current_year).end_of_year)

    # Initialisation des arrêts maladie pour l'année en cours
    @current_year_sick_leaves = @employee.events.where(event_type: 'arrêt_maladie', start_date: Date.new(current_year)..Date.new(current_year).end_of_year)

    @leave_counts = {
      (current_year - 2) => @employee.events.where(event_type: 'congé', status: 'approuvé', start_date: Date.new(current_year - 2)..Date.new(current_year - 2).end_of_year).sum(:leave_days_count),
      (current_year - 1) => @employee.events.where(event_type: 'congé', status: 'approuvé', start_date: Date.new(current_year - 1)..Date.new(current_year - 1).end_of_year).sum(:leave_days_count),
      current_year => @current_year_leaves.sum(:leave_days_count)
    }
    @event = @employee.events.new # Initialisation pour éviter le nil
    @expense = @employee.expenses.new # 👈 Définit une nouvelle note de frais

    # Vérifier et définir l'année sélectionnée
    @selected_year = params[:year].present? ? params[:year].to_i : Date.today.year

    # Debug pour voir l'année sélectionnée
    puts "🔍 Année sélectionnée : #{@selected_year}"

    # Récupérer les dépenses approuvées de l'année sélectionnée
    approved_expenses = Expense.where(employee: @employee, status: 'approuvé')
                               .where("extract(year from date) = ?", @selected_year)
                               .group("extract(month from date)")
                               .sum(:amount)

    puts "📊 Dépenses approuvées par mois (Raw SQL) : #{approved_expenses.inspect}"

    # Assurer que tous les mois sont présents même si vides
    @approved_expenses_by_month = Hash.new(0)

    @employee.expenses.where(status: "approuvé", date: Date.new(@selected_year)..Date.new(@selected_year, 12, 31)).each do |expense|
      month_index = expense.date.month - 1 # Mois de 1 à 12 => Index de 0 à 11
      @approved_expenses_by_month[month_index] += expense.amount
    end

    # Assurer que tous les mois sont présents, même à 0 €
    @approved_expenses_by_month = (0..11).map { |i| @approved_expenses_by_month[i] || 0 }
    @expenses_json = @approved_expenses_by_month.to_json

    puts "📊 Dépenses par mois envoyées à la vue : #{@approved_expenses_by_month.inspect}"

    puts "📆 Année sélectionnée : #{@selected_year}"
    puts "🔍 Dépenses trouvées avant regroupement :"
    @employee.expenses.where(status: "approuvé", date: Date.new(@selected_year)..Date.new(@selected_year, 12, 31)).each do |expense|
      puts "   - #{expense.date} : #{expense.amount} €"

      @approved_expenses_by_month = (0..11).map do |i|
        (@approved_expenses_by_month[i] || 0).to_f
      end
    end
  end

  def new
    @employee = Employee.new
  end

  def create
    Rails.logger.info "===== Début de la méthode create ====="
    Rails.logger.info "Params reçus : #{params.inspect}"

    # Créer ou récupérer l'utilisateur associé
    user_email = params[:employee][:email]
    user = User.find_by(email: user_email)

    unless user
      Rails.logger.info "Aucun utilisateur trouvé pour l'email #{user_email}, création d'un nouvel utilisateur."
      user = User.new(
        email: user_email,
        password: SecureRandom.hex(8), # Génère un mot de passe aléatoire
        role: "employee"
      )
      unless user.save
        Rails.logger.error "Erreur lors de la création de l'utilisateur : #{user.errors.full_messages.join(", ")}"
        render :new, status: :unprocessable_entity and return
      end
    end

    # Créer l'employé et l'associer à l'utilisateur
    @employee = Employee.new(employee_params)
    @employee.user = user

    # Prioriser les champs personnalisés pour group et position
    @employee.group = params[:employee][:new_group].presence || @employee.group
    @employee.position = params[:employee][:new_position].presence || @employee.position

    if @employee.save
      Rails.logger.info "Employé créé avec succès : #{@employee.inspect}"
      redirect_to employees_path, notice: "Employé créé avec succès"
    else
      Rails.logger.error "Erreur lors de la sauvegarde de l'employé : #{@employee.errors.full_messages.join(", ")}"
      render :new, status: :unprocessable_entity
    end
    Rails.logger.info "===== Fin de la méthode create ====="
  end


  def edit; end

  def update
    if @employee.update(employee_params)
      redirect_to @employee, notice: "Employé mis à jour avec succès."
    else
      render :edit
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    redirect_to employees_path, notice: "Employé supprimé avec succès."
  end

  def check_availability
    date = Date.parse(params[:date])
    employee = current_user.employee

    is_available = !employee.events.where(start_date: date, event_type: ['congé', 'arrêt_maladie', 'heures_supplémentaires']).exists?

    render json: { available: is_available }
  end

  def expenses_by_year
    @employee = Employee.find(params[:id])
    year = params[:year].to_i

    Rails.logger.debug "🔍 API expenses_by_year - Employee ID: #{params[:id]}, Year: #{year}"

    start_date = Date.new(year, 1, 1)
    end_date = Date.new(year, 12, 31)

    approved_expenses = Array.new(12, 0)
    @employee.expenses.where(status: 'approuvé', date: start_date..end_date).each do |expense|
      approved_expenses[expense.date.month - 1] += expense.amount
    end

    render json: { year: year, expenses: approved_expenses }
  end


  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:firstname, :lastname, :email, :phone, :address, :position, :group, :hoursalary, :admin)
  end

end
