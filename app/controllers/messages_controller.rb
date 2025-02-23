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
