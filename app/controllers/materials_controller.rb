class MaterialsController < ApplicationController
  def new
    @quote = Quote.find(params[:quote_id])
    @item  = @quote.items.find(params[:item_id])
    @material = @item.materials.build
  end

  def create
    @quote = Quote.find(params[:quote_id])
    @item  = @quote.items.find(params[:item_id])
    @material = @item.materials.build(material_params)

    if @material.save
      redirect_to @quote, notice: 'Matériel ajouté avec succès.'
    else
      redirect_to @quote, alert: 'Erreur lors de l’ajout du matériel.'
    end
  end

  private

  def material_params
    params.require(:material).permit(:name, :unit_price, :margin, :quantity)
  end
end
