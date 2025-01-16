class QuotesController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy] # Ne pas inclure `index` ici

  def index
    @quotes = Quote.all
  end

  def show
    @quote = Quote.find(params[:id])
  end

  def new
    @quote = Quote.new
    @quote.number = generate_number
  end

  def create
    @quote = Quote.new(quote_params)
    if @quote.save
      redirect_to quotes_path, notice: "Devis créé avec succès."
    else
      render :new
    end
  end

  def edit
    @quote = Quote.find_by(id: params[:id])
    if @quote.nil?
      redirect_to quotes_path, alert: "Devis introuvable."
    end
  end

  def update
    @quote = Quote.find_by(id: params[:id])
    if @quote.nil?
      redirect_to quotes_path, alert: "Devis introuvable."
    else
      if @quote.update(quote_params)
        redirect_to @quote, notice: "Devis mis à jour avec succès."
      else
        render :edit
      end
    end
  end

  def destroy
    @quote.destroy
    redirect_to quotes_path, notice: "Devis supprimé avec succès."
  end

  private

  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id]
  end

  def quote_params
    params.require(:quote).permit(:number, :status, :project_id)
  end

  def generate_number
    current_year = Time.now.year
    current_month = Time.now.strftime("%m") # Mois format "01"

    # Trouver le dernier numéro généré pour l'année et le mois en cours
    last_quote = Quote.where("number LIKE ?", "Devis_#{current_year}#{current_month}_%")
                      .order(:created_at)
                      .last

    # Calculer l'incrément
    last_increment = if last_quote.present?
                       last_quote.number.split("_").last.to_i
                     else
                       0
                     end

    new_increment = last_increment + 1
    "Devis_#{current_year}#{current_month}_#{new_increment.to_s.rjust(4, '0')}"
  end

end
