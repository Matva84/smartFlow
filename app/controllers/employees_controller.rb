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


  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:firstname, :lastname, :address, :phone, :email, :group, :position, :hoursalary, default_days_off: [])
  end


end
