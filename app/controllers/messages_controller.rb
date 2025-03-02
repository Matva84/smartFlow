class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    messageable = params[:messageable_type].constantize.find(params[:messageable_id])

    # Créer le message
    message = Message.new(
      content: params[:message][:content],
      user: current_user,
      messageable: messageable,
      full_name: determine_full_name(current_user)
    )

    if messageable.is_a?(Employee)
      message.recipient_id = messageable.user_id
    end

    # Attacher les documents si présents
    if params[:message][:documents].present?
      params[:message][:documents].each do |doc|
        message.documents.attach(doc)
      end
    end

    if message.save
      # Au lieu de diffuser ici un payload
      # on appelle la méthode de classe du channel
      CommunicationChannel.broadcast_message(message)

      render json: { status: 'ok' }
    else
      render json: { status: 'error', errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def mark_as_read
    message = Message.find(params[:id])

    # Vérifier que current_user est le destinataire
    # (Dans votre schéma, vous avez un champ `recipient_id` ou `employee_id` pour savoir qui est le destinataire)
    if message.recipient_id == current_user.id && message.read_at.nil?
      message.mark_as_read!
      render json: { status: 'ok', read_at: message.read_at }
    else
      render json: { status: 'error', message: "Impossible de marquer comme lu" }, status: :unprocessable_entity
    end
  end

  private

  def determine_full_name(user)
    if user.role == 'employee'
      employee_record = ::Employee.find_by(user_id: user.id)
      employee_record ? "#{employee_record.firstname} #{employee_record.lastname}" : user.email
    elsif user.role == 'customer'
      client_record = ::Client.find_by(email: user.email)
      client_record ? "#{client_record.firstname} #{client_record.lastname}" : user.email
    elsif user.role == 'admin'
      employee_record = ::Employee.find_by(email: user.email)
      employee_record ? "#{employee_record.firstname} #{employee_record.lastname}" : user.email
    else
      user.name rescue user.email
    end
  end
end
