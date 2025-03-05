class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quote, only: [:create]
  before_action :set_item, only: [:destroy]

  def new
    @item = @quote.items.build
  end

  def create
    @item = @quote.items.build(item_params)

    #if @item.save
    #  redirect_to quote_path(@quote), notice: "L'item a été ajouté avec succès."
    #else
    #  redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de l'ajout de l'item."
    #end
    # Par exemple, si `duration` est vide, on cherche un Item équivalent
    if @item.duration.blank?
      existing = Item.where(category: @item.category, description: @item.description).order(created_at: :desc).first
      if existing
        @item.duration = existing.duration
        @item.nb_people = existing.nb_people
        # etc. pour récupérer d’autres champs
      end
    end

    if @item.save
      # Méthode (optionnelle) pour recalculer le total du devis
      @quote.recalculate_total!

      redirect_to quote_path(@quote), notice: "Item ajouté avec succès."
    else
      # En cas d’erreur de validation, on réaffiche la page du devis
      # avec les messages d’erreur (attention à gérer l’affichage)
      flash.now[:alert] = "Erreur lors de la création de l’item."
      render "quotes/show"  # ou le template partiel qui contient le formulaire
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    #@quote = Quote.find(params[:quote_id])
    #@item = @quote.items.find(params[:id])

    #if @item.update(item_params)
    #  redirect_to quote_path(@quote), notice: "L'item a été modifié avec succès."
    #else
    #  redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de la modification de l'item."
    #end
    if @item.update(item_params)
      @quote.recalculate_total!
      redirect_to quote_path(@quote), notice: "Item mis à jour avec succès."
    else
      flash.now[:alert] = "Erreur lors de la mise à jour de l’item."
      render "quotes/show"
    end
  end

  def destroy
    #if @item.destroy
    #  redirect_to quote_path(@quote), notice: "L'item a été supprimé avec succès."
    #else
    #  redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de la suppression de l'item."
    #end
    @item.destroy
    @quote.recalculate_total!
    redirect_to quote_path(@quote), notice: "Item supprimé avec succès."
  end

  def categories
    # Récupérer la liste *unique* de catégories
    categories = Item.distinct.pluck(:category).compact
    render json: categories
  end

  def descriptions
    # Filtrer par catégorie
    category = params[:category]
    descriptions = Item.where(category: category).distinct.pluck(:description).compact
    render json: descriptions
  end

  def last_item_info
    # Récupérer le dernier Item ayant cette catégorie et cette description
    category    = params[:category]
    description = params[:description]
    item = Item.where(category: category, description: description).order(created_at: :desc).first

    if item.present?
      # Retourne les champs pertinents pour pré‐remplir le formulaire
      render json: {
        duration:        item.duration,
        nb_people:       item.nb_people,
        material:        item.material,
        unit_price_ht:   item.unit_price_ht,
        quantity:        item.quantity,
        # Et tous les autres champs que vous souhaitez renvoyer
        # human_margin, vat_value, etc.
      }
    else
      render json: {}
    end
  end

  private

  #def set_quote
  #  Rails.logger.debug "Params for quote_id: #{params[:quote_id]}"
  #  @quote = Quote.find(params[:quote_id])
  #rescue ActiveRecord::RecordNotFound
  #  redirect_to quotes_path, alert: "Le devis est introuvable."
  #end

  #def set_item
  #  Rails.logger.debug "Params for item id: #{params[:id]}"
  #  @item = @quote.items.find(params[:id])
  #rescue ActiveRecord::RecordNotFound
  #  redirect_to quote_path(@quote), alert: "L'item est introuvable."
  #end

  #def item_params
  #  params.require(:item).permit(:category, :description, :duration, :nb_people, :hourly_cost, :human_margin, :human_total_cost, :material, :unit_price_ht, :quantity, :total_price_ht, :material_margin, :vat_value, :material_cost, :total_cumulative, :total_margin)
  #end

  def set_quote
    @quote = Quote.find(params[:quote_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to quotes_path, alert: "Devis introuvable."
  end

  def set_item
    @item = @quote.items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to quote_path(@quote), alert: "Item introuvable."
  end

  def item_params
    params.require(:item).permit(
      :category,
      :description,
      :duration,
      :nb_people,
      :material,
      :unit_price_ht,
      :quantity,
      :hourly_cost,
      :human_margin,
      :vat_value
      # + tous les attributs que vous avez dans votre Item
    )
  end
end
