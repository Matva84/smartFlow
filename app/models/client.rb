class Client < ApplicationRecord
  validates :firstname, :lastname, :email, :phone, presence: true
  validates :email, uniqueness: true
  has_many :messages, as: :messageable, dependent: :destroy
  has_many :projects
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  def project_status
    if projects.any?
      # Choisir ici le projet pertinent (ici, le dernier projet ajouté)
      current_project = projects.last
      case current_project.progression
      when 0
        'not_started'
      when 100
        'completed'
      else
        'in_progress'
      end
    else
      'unknown'
    end
  end

end
