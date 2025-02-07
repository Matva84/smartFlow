class Employee < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :events, dependent: :destroy
  has_and_belongs_to_many :projects

  # Validations
  validates :firstname, :lastname, :email, presence: true
  validates :email, uniqueness: true
  validate :validate_default_days_off

  # Par défaut, les jours de congés sont samedi (6) et dimanche (0)
  after_initialize :set_default_days_off, if: :new_record?
  attribute :default_days_off, :integer, array: true, default: [0, 6]
  
  # Exemple de méthode pour le nom complet
  def full_name
    "#{firstname} #{lastname}"
  end

  # Méthode pour savoir si l'employé est présent un jour donné
  def present_on?(date)
    !default_days_off.include?(date.wday) && !events.where("start_date <= ? AND end_date >= ?", date, date).exists?
  end

  # Retourne l'événement pour une date donnée (ou nil s'il n'y a pas d'événement)
  def event_on(date)
    events.find_by("start_date <= ? AND end_date >= ?", date, date)
  end

  # Retourne le type d'événement pour une date donnée (ou nil s'il n'y a pas d'événement)
  def event_type_on(date)
    event_on(date)&.event_type
  end

  private

  def set_default_days_off
    self.default_days_off = [6, 0] if default_days_off.empty?
  end

  def validate_default_days_off
    invalid_days = default_days_off - (0..6).to_a
    if invalid_days.any?
      errors.add(:default_days_off, "contient des jours invalides : #{invalid_days.join(', ')}")
    end
  end
end
