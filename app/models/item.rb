class Item < ApplicationRecord
  belongs_to :quote

  def total_price_ht
    # Si c’est un total direct (quantité x prix unitaire),
    # ajustez selon votre logique (marge, TVA, etc.)
    quantity.to_f * unit_price_ht.to_f
  end
  
end
