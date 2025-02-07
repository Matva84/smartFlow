class Event < ApplicationRecord
  belongs_to :employee

  validates :event_type, presence: true, inclusion: { in: %w[congé télétravail arrêt_maladie heures_supplémentaires] }
  validates :start_date, :end_date, presence: true
  validate :start_date_before_end_date
  validate :validate_part_of_day
  validate :start_date_cannot_be_in_the_past
  #validate :cannot_schedule_on_non_working_days
  validate :calculate_leave_days
  validate :telework_not_on_non_working_days_or_conflicting_events
  validate :validate_overtime_conditions, if: -> { event_type == 'heures_supplémentaires' }

  validates :employee, presence: true

  STATUSES = %w[en_attente approuvé refusé]
  validates :status, inclusion: { in: STATUSES }

  before_save :calculate_leave_days

  private

  def start_date_before_end_date
    if start_date > end_date
      errors.add(:start_date, "ne peut pas être après la date de fin")
    end
  end

  def validate_part_of_day
    return if event_type == 'heures_supplémentaires'  # Ignore la validation pour les heures supplémentaires

    if start_date == end_date
      # Si la date de début et de fin sont identiques, `part_of_day` peut être vide (journée entière)
      if part_of_day.nil?
        self.part_of_day = "" # On force la valeur vide pour éviter l'erreur de validation
      end
    elsif start_date != end_date
      # Si plusieurs jours sont sélectionnés, part_of_day doit être vide
      if part_of_day.present?
        errors.add(:part_of_day, "ne peut être défini que si les dates de début et de fin sont identiques")
      end
    end
  end

  def start_date_cannot_be_in_the_past
    if event_type == 'congé' && start_date.present? && start_date < Date.today
      errors.add(:start_date, "ne peut pas être antérieure à aujourd'hui")
    end
  end

  def cannot_schedule_on_non_working_days
    non_working_days = employee.default_days_off
    (start_date..end_date).each do |date|
      if non_working_days.include?(date.wday)
        errors.add(:base, "Impossible de poser un congé incluant des jours non travaillés (#{I18n.l(date, format: :long)})")
      end
    end
  end

  def calculate_leave_days
    return unless event_type == 'congé'

    total_days = (start_date..end_date).to_a

    # Filtrer les jours non travaillés (week-ends et jours de congé par défaut)
    working_days = total_days.reject do |date|
      employee.default_days_off.include?(date.wday)
    end

    # Si part_of_day est vide ou non sélectionné → Journée complète
    if part_of_day.blank?
      self.leave_days_count = working_days.size
    elsif part_of_day.present?
      self.leave_days_count = 0.5
    end
  end

  def telework_not_on_non_working_days_or_conflicting_events
    return unless event_type == 'télétravail'

    # Vérification des jours non travaillés (week-ends et jours de repos)
    (start_date..end_date).each do |date|
      if employee.default_days_off.include?(date.wday)
        errors.add(:base, "Impossible de poser un jour de télétravail sur un jour non travaillé (#{I18n.l(date, format: :long)}).")
        return
      end
    end

    # Vérification des conflits avec des congés ou des arrêts maladie
    conflicting_events = employee.events.where(event_type: ['congé', 'arrêt_maladie'])
                                        .where("start_date <= ? AND end_date >= ?", end_date, start_date)

    if conflicting_events.exists?
      errors.add(:base, "Impossible de poser un jour de télétravail sur un jour de congé ou d'arrêt maladie.")
    end
  end

  def validate_overtime_conditions
    # Vérifie si le jour est un week-end
    if start_date.saturday? || start_date.sunday?
      errors.add(:base, "Impossible de poser des heures supplémentaires un week-end.")
    end

    # Vérifie si le jour est un jour de congé ou un arrêt maladie
    conflicting_event = employee.events.where.not(id: id).where(start_date: start_date, event_type: ['congé', 'arrêt_maladie']).first
    if conflicting_event
      errors.add(:base, "Impossible de poser des heures supplémentaires un jour de congé ou d'arrêt maladie.")
    end

    # Vérifie si des heures supplémentaires ou un autre événement ont déjà été posés pour ce jour
    existing_overtime = employee.events.where.not(id: id).where(start_date: start_date, event_type: 'heures_supplémentaires').exists?
    if existing_overtime
      errors.add(:base, "Des heures supplémentaires ont déjà été posées pour ce jour.")
    end
  end

end
