class Item < ApplicationRecord
  belongs_to :quote
  has_many :materials, dependent: :destroy
  before_save :compute_totals
  after_save :update_quote_totals
  after_destroy :update_quote_totals

  def total_price_ht
    (quantity || 0) * (unit_price_ht || 0)
  end

  private

  def compute_totals
    cost_without_margin = nb_people.to_f * duration.to_f * hourly_cost.to_f
    margin_rate = human_margin.to_f / 100.0
    margin_amount = cost_without_margin * margin_rate
    self.total_margin = margin_amount
    self.human_total_cost = cost_without_margin + margin_amount
    Rails.logger.info "DEBUG compute_totals => cost_without_margin=#{cost_without_margin}, margin_amount=#{margin_amount}, total_price_ht=#{self.human_total_cost}"
  end
  def update_quote_totals
    quote.recalculate_total!
  end
end
