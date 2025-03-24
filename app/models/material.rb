class Material < ApplicationRecord
  belongs_to :item
  before_save :calculate_total_price
  after_save :update_quote_totals
  after_destroy :update_quote_totals

  private

  def calculate_total_price
    raw_price = quantity.to_f * unit_price.to_f * (1 + margin.to_f / 100.0)
    self.total_price = raw_price.round(2)
    raw_margin = quantity.to_f * unit_price.to_f * (margin.to_f / 100.0)
    self.total_margin = raw_margin.round(2)
  end
  def update_quote_totals
    item.quote.recalculate_total!
  end
end
