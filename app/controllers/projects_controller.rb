class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  before_action :set_clients, only: [:new, :edit]
  before_action :set_employees, only: [:new, :edit]

  def index
    @projects = Project.all
    @projects = Project.order(:progression)
  end

  def show
    @employees = Employee.all
  end

  def new
    @project = Project.new
    set_clients
    set_employees
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to @project, notice: "Projet créé avec succès."
    else
      set_clients
      set_employees
      render :new
    end
  end

  def edit
    set_clients
    set_employees
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Projet mis à jour avec succès."
    else
      set_clients
      set_employees
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "Projet supprimé avec succès."
  end

  def assign_employees
    @project = Project.find(params[:id])

    # Mettre à jour les employés assignés
    @project.employees = Employee.where(id: params[:employee_ids])

    if @project.save
      redirect_to @project, notice: "Les employés ont été mis à jour avec succès."
    else
      redirect_to @project, alert: "Une erreur s'est produite lors de la mise à jour des employés."
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def set_clients
    @clients = Client.all
  end

def set_employees
    @employees = Employee.all
  end

  def project_params
    params.require(:project).permit(
      :name, :description, :address, :latitude, :longitude, :start_at, :end_at,
      :initial_start_at, :initial_end_at, :totalbudget, :progression,
      :human_cost, :material_cost, :customer_budget, :total_expenses, :client_id,
      employee_ids: []
    )
  end
end
