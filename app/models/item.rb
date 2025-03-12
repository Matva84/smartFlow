class Item < ApplicationRecord
  belongs_to :quote
  has_many :materials, dependent: :destroy

  def total_price_ht
    # Si c’est un total direct (quantité x prix unitaire),
    # ajustez selon votre logique (marge, TVA, etc.)
    (quantity || 0) * (unit_price_ht || 0)
  end

end
