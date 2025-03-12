class QuotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy] # Ne pas inclure `index` ici
  before_action :set_quote, only: [:show, :edit, :update, :destroy, :duplicate]
  before_action :set_item, only: [:destroy]

  def index
    @quotes = Quote.all

    # Filtrage par statut
    if params[:status].present?
      @quotes = @quotes.where(status: params[:status])
    end

    # Filtrage par période
    if params[:period].present?
      case params[:period]
      when "last_year"
        @quotes = @quotes.where(created_at: 1.year.ago.beginning_of_year..1.year.ago.end_of_year)
      when "this_year"
        @quotes = @quotes.where(created_at: Time.current.beginning_of_year..Time.current.end_of_year)
      when "this_month"
        @quotes = @quotes.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month)
      when "last_month"
        last_month = Time.current.last_month
        @quotes = @quotes.where(created_at: last_month.beginning_of_month..last_month.end_of_month)
      end
    end

    @quotes = @quotes.order(created_at: :desc) # Tri par date de création
  end


  def show
    @quote = Quote.find(params[:id])
    @categories = Item.distinct.pluck(:category).compact
    @descriptions = Item.distinct.pluck(:description).compact
  end

  def new
    @quote = Quote.new
    @quote.number = @quote.generate_temporary_number
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
    if @item.destroy
      redirect_to quote_path(@quote), notice: "L'item a été supprimé avec succès."
    else
      redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de la suppression de l'item."
    end
  end

  def duplicate
    # Créez une copie du devis existant
    duplicate_quote = @quote.dup
    duplicate_quote.parent_quote = @quote

    # Laisser la méthode `before_create` générer le nouveau numéro
    if duplicate_quote.save
      # Dupliquer les items associés
      @quote.items.each do |item|
        duplicate_item = item.dup
        duplicate_item.quote = duplicate_quote
        duplicate_item.save
      end

      redirect_to quote_path(duplicate_quote), notice: "Le devis #{duplicate_quote.number} a été dupliqué avec succès avec tous ses items."
    else
      redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de la duplication du devis."
    end
  end

  def update_status
    @quote = Quote.find(params[:id])

    if @quote.update(status: params[:quote][:status])
      redirect_to quotes_path, notice: "Le statut du devis a été mis à jour avec succès."
    else
      redirect_to quotes_path, alert: "Une erreur est survenue lors de la mise à jour du statut."
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id]
  end

  def quote_params
    params.require(:quote).permit(:number, :status, :project_id)
  end

  def set_quote
    @quote = Quote.find(params[:id])
    rescue ActiveRecord::RecordNotFound
    redirect_to quotes_path, alert: "Le devis est introuvable."
  end
  def set_item
    @item = @quote.items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to quote_path(@quote), alert: "L'item est introuvable."
  end
end
