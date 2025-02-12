class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_quote, only: [:create]
  before_action :set_item, only: [:destroy]

  def new
    @item = @quote.items.build
  end

  def create
    @item = @quote.items.build(item_params)

    if @item.save
      redirect_to quote_path(@quote), notice: "L'item a été ajouté avec succès."
    else
      redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de l'ajout de l'item."
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @quote = Quote.find(params[:quote_id])
    @item = @quote.items.find(params[:id])

    if @item.update(item_params)
      redirect_to quote_path(@quote), notice: "L'item a été modifié avec succès."
    else
      redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de la modification de l'item."
    end
  end

  def destroy
    if @item.destroy
      redirect_to quote_path(@quote), notice: "L'item a été supprimé avec succès."
    else
      redirect_to quote_path(@quote), alert: "Une erreur est survenue lors de la suppression de l'item."
    end
  end

  private

  def set_quote
    Rails.logger.debug "Params for quote_id: #{params[:quote_id]}"
    @quote = Quote.find(params[:quote_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to quotes_path, alert: "Le devis est introuvable."
  end

  def set_item
    Rails.logger.debug "Params for item id: #{params[:id]}"
    @item = @quote.items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to quote_path(@quote), alert: "L'item est introuvable."
  end

  def item_params
    params.require(:item).permit(:category, :description, :duration, :nb_people, :hourly_cost, :human_margin, :human_total_cost, :material, :unit_price_ht, :quantity, :total_price_ht, :material_margin, :vat_value, :material_cost, :total_cumulative, :total_margin)
  end

end
