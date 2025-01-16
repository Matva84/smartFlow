#class Quote < ApplicationRecord
#  belongs_to :project

#  validates :number, presence: true, uniqueness: true
##  validates :status, presence: true, inclusion: { in: %w[Création Prêt\ à\ envoyer Envoyé Accepté Rejeté A\ modifier] }

  # Définir une valeur par défaut pour le statut
#  after_initialize :set_default_status, if: :new_record?

#  private

#  def set_default_status
#    self.status ||= "Création"
#    self.total ||= 0
#  end
#end
class Quote < ApplicationRecord
  belongs_to :project

  validates :status, presence: true, inclusion: { in: %w[Création Prêt\ à\ envoyer Envoyé Accepté Rejeté A\ modifier] }

  # Générer un numéro automatiquement avant la création
  before_create :generate_number
  after_initialize :set_default_status, if: :new_record?

  private

  def generate_number
    current_year = Time.now.year
    current_month = Time.now.strftime("%m") # Mois au format "01", "02", etc.

    # Trouver le dernier numéro utilisé pour l'année et le mois actuels
    last_quote = Quote.where("number LIKE ?", "Devis_#{current_year}#{current_month}_%")
                      .order(:created_at)
                      .last

    # Extraire le dernier incrément si un devis existe, sinon démarrer à 1
    last_increment = if last_quote.present?
                       last_quote.number.split("_").last.to_i
                     else
                       0
                     end

    # Générer le nouveau numéro
    new_increment = last_increment + 1
    self.number = "Devis_#{current_year}#{current_month}_#{new_increment.to_s.rjust(4, '0')}" # Exemple: "Devis_202501_0001"
  end
  
  def set_default_status
    self.status ||= "Création"
    self.total ||= 0
  end
end
