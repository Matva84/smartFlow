class Message < ApplicationRecord
  belongs_to :user
  belongs_to :messageable, polymorphic: true

  # Permet d'attacher plusieurs documents au message
  has_many_attached :documents

  # Validation personnalisée si vous souhaitez autoriser un message sans contenu mais avec documents
  validate :content_or_documents_present

  # Indique si le message est lu
  def read?
    read_at.present?
  end

  # Marquer comme lu
  def mark_as_read!
    update(read_at: Time.current) if read_at.nil?
  end

  private

  def content_or_documents_present
    if content.blank? && !documents.attached?
      errors.add(:base, "Veuillez saisir un message ou joindre au moins un document.")
    end
  end
end
