class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    messageable = params[:messageable_type].constantize.find(params[:messageable_id])

    message = Message.new(
      content: params[:message][:content],
      user: current_user,
      messageable: messageable,
      full_name: determine_full_name(current_user)
    )

    # ─────────────────────────────────────────────────────────────────────────────
    # Gérer le cas Admin => Employé
    # ─────────────────────────────────────────────────────────────────────────────
    if current_user.role == 'admin' && messageable.is_a?(Employee)
      # L'admin est l'expéditeur, l'employé (messageable) est le destinataire
      message.recipient_id = messageable.user_id
      Rails.logger.debug "create => Admin (user_id=#{current_user.id}) envoie un message à l'employé user_id=#{messageable.user_id}"

    # ─────────────────────────────────────────────────────────────────────────────
    # Gérer le cas Employé => Admin
    # ─────────────────────────────────────────────────────────────────────────────
    elsif current_user.role == 'employee'
      # L'employé est l'expéditeur, donc le destinataire est l'admin
      # Trouver l'admin (selon votre logique : si vous avez un seul admin, ou un user particulier)
      admin_user = User.find_by(role: 'admin')  # ou find_by(email: "admin@example.com")
      if admin_user
        message.recipient_id = admin_user.id
        Rails.logger.debug "create => Employé (user_id=#{current_user.id}) envoie un message à l'admin user_id=#{admin_user.id}"
      else
        Rails.logger.error "create => AUCUN admin trouvé ! On laisse recipient_id=nil"
      end

    # ─────────────────────────────────────────────────────────────────────────────
    # Autres cas éventuels
    # ─────────────────────────────────────────────────────────────────────────────
    else
      Rails.logger.debug "create => Cas non géré : current_user.role=#{current_user.role}, messageable=#{messageable.inspect}"
    end

    # Attacher des documents si présents
    if params[:message][:documents].present?
      params[:message][:documents].each do |doc|
        message.documents.attach(doc)
      end
    end

    if message.save
      Rails.logger.debug "MessagesController#create => Message #{message.id} créé, recipient_id=#{message.recipient_id}, read_at=#{message.read_at.inspect}"
      CommunicationChannel.broadcast_message(message)
      render json: { status: 'ok' }
    else
      Rails.logger.error "Erreur lors de la création du message : #{message.errors.full_messages.join(", ")}"
      render json: { status: 'error', errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def mark_as_read
    message = Message.find(params[:id])
    # Vérifier que current_user est le destinataire
    if message.recipient_id == current_user.id && message.read_at.nil?
      Rails.logger.debug "MessagesController#mark_as_read => Marquage lu pour le message #{message.id}"
      message.update(read_at: Time.current)
      CommunicationChannel.broadcast_read_status(message)
      render json: { status: 'ok', read_at: message.read_at }
    else
      Rails.logger.debug "MessagesController#mark_as_read => Impossible de marquer lu pour le message #{message.id} (recipient_id=#{message.recipient_id}, read_at=#{message.read_at.inspect})"
      render json: { status: 'error' }, status: :unprocessable_entity
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
