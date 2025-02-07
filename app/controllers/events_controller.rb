class EventsController < ApplicationController
  before_action :set_employee, only: [:new, :create, :destroy, :approve, :reject] # Si 'show' n'existe pas, cela cause l'erreur
  before_action :set_event, only: [:approve, :reject, :destroy]

  def index
    @events = @employee.events.order(start_date: :asc)
  end

  def new
    @event = @employee.events.new
  end

  def create
    @event = @employee.events.new(event_params)
    @event.status = 'en_attente'  # Par défaut, l'événement est en attente de validation

    # Si l'événement est des heures supplémentaires, s'assurer que la date de fin est la même que la date de début
    if @event.event_type == 'heures_supplémentaires'
      @event.end_date = @event.start_date
    end

    if @event.save
      redirect_to employee_path(@employee), notice: "Demande d'événement soumise pour validation."
    else
      render :new
    end
  end

  def approve
    if @event.update(status: 'approuvé')
      redirect_to employees_path, notice: "L'événement a été approuvé."
    else
      redirect_to employees_path, alert: "Impossible d'approuver l'événement."
    end
  end

  def reject
    if @event.update(status: 'refusé')
      redirect_to employees_path, notice: "L'événement a été refusé."
    else
      redirect_to employees_path, alert: "Impossible de refuser l'événement."
    end
  end


  def destroy
    if @event.event_type == 'congé'
      # Décrémenter le compteur de congés de l'employé
      if @event.leave_days_count.present?
        @employee.total_leaves_taken ||= 0  # Assure que le compteur est bien initialisé
        @employee.total_leaves_taken -= @event.leave_days_count
        @employee.save
      end
    end

    @event.destroy
    redirect_to employee_path(@employee), notice: "L'événement a été supprimé avec succès."
  end

  def pending_count
    pending_events_count = Event.where(status: 'en_attente').count
    render json: { pending_count: pending_events_count }
  end

  def approved_overtime_hours
    total_hours = Event.where(event_type: 'heures_supplémentaires', status: 'approuvé').sum(:overtime_hours)
    render json: { total_overtime_hours: total_hours }
  end


  private

  def set_employee
    @employee = Employee.find(params[:employee_id])
  end

  def event_params
    params.require(:event).permit(:event_type, :start_date, :end_date, :part_of_day, :overtime_hours)
  end

  def set_event
    @event = @employee.events.find(params[:id])
  end
end
