class Quote < ApplicationRecord
  belongs_to :project
  belongs_to :parent_quote, class_name: "Quote", optional: true
  has_many :amendments, class_name: "Quote", foreign_key: "parent_quote_id", dependent: :nullify
  has_many :items, dependent: :destroy # Assure que les items liés sont accessibles

  validates :status, presence: true, inclusion: { in: %w[Création Prêt\ à\ envoyer Envoyé Accepté Rejeté A\ modifier] }

  # Générer un numéro automatiquement avant la création
  before_create :generate_number
  after_initialize :set_default_status, if: :new_record?

  def generate_amendment_number
    # Extrait la base du numéro sans suffixe alphabétique
    base_number = number.split("_")[0..2].join("_") # Exemple : "Devis_202501_0003"

    # Trouver les amendements existants pour ce numéro de base
    amendments = Quote.where("number LIKE ?", "#{base_number}_%").pluck(:number)

    # Récupérer le dernier suffixe alphabétique
    last_suffix = amendments.map { |num| num.split("_").last }.select { |s| s =~ /^[a-z]$/ }.max

    # Déterminer le prochain suffixe
    next_suffix = last_suffix ? last_suffix.next : "a"

    "#{base_number}_#{next_suffix}"
  end

  def generate_temporary_number
    current_year = Time.now.year
    current_month = Time.now.strftime("%m")
    quote_prefix = Setting.get("quote_prefix")
    last_quote = Quote.where("number LIKE ?", "#{quote_prefix}_#{current_year}#{current_month}_%")
                      .order(:created_at)
                      .last

    last_increment = if last_quote.present?
                       last_quote.number.split("_").last.to_i
                     else
                       0
                     end

    "#{quote_prefix}_#{current_year}#{current_month}_#{(last_increment + 1).to_s.rjust(4, '0')}"
  end

  def recalculate_total!
      # Somme des totaux et marges de tous les items
      total_items = items.sum(&:human_total_cost)
      margin_items = items.sum(&:total_margin)

      # Optionnel : si vos items ont des matériaux à additionner séparément,
      # vous pouvez, par exemple, les ajouter ainsi (si les colonnes existent dans Material)
      total_materials = items.joins(:materials).sum("materials.total_price")
      margin_materials = items.joins(:materials).sum("materials.total_margin")

      # Si vous souhaitez combiner les deux :
      total_ht = total_items + total_materials
      total_margin = margin_items + margin_materials

      update(total_ht: total_ht, margin: total_margin)
  end

  private


  def set_default_status
    self.status ||= "Création"
    self.total ||= 0
  end

  # Calculer le prochain suffixe alphabétique pour un amendement
  def next_amendment_suffix
    last_amendment = amendments.order(:created_at).last

    if last_amendment&.number&.match?(/[a-z]$/)
      # Incrémenter le dernier caractère alphabétique
      last_amendment.number[-1].next
    else
      # Premier suffixe pour un devis parent
      'a'
    end
  end

  def generate_number
    self.number ||= generate_temporary_number
  end

end
