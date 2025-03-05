class CommunicationChannel < ApplicationCable::Channel
  def subscribed
    if params[:messageable_type].present? && params[:messageable_id].present?
      stream_from "#{params[:messageable_type].downcase}_#{params[:messageable_id]}_channel"
    else
      reject
    end
  end

  # Méthode de classe pour diffuser un message existant
  def self.broadcast_message(message)
    payload = {
      message_id: message.id,            # AJOUT pour identifier le message
      messageable_id: message.messageable_id,  # AJOUT
      recipient_id: message.recipient_id,# AJOUT pour savoir à qui il est destiné
      read_at: message.read_at,          # AJOUT pour l'état de lecture
      message: message.content,
      user: message.user.email,
      full_name: message.full_name,
      sent_at: message.created_at.strftime("%d/%m à %H:%M"),
      document_urls: if message.documents.attached?
                       message.documents.map do |doc|
                         if doc.blob.content_type.start_with?('image')
                           {
                             thumbnail_url: Rails.application.routes.url_helpers.url_for(
                               doc.variant(resize_to_limit: [100, 100]).processed
                             ),
                             original_url: Rails.application.routes.url_helpers.url_for(doc),
                             is_image: true
                           }
                         else
                           {
                             thumbnail_url: nil,
                             original_url: Rails.application.routes.url_helpers.url_for(doc),
                             is_image: false
                           }
                         end
                       end
                     else
                       []
                     end
    }

    Rails.logger.info "CommunicationChannel.broadcast_message => Payload: #{payload.inspect}"

    channel_name = "#{message.messageable_type.downcase}_#{message.messageable_id}_channel"
    ActionCable.server.broadcast(channel_name, payload)
  end


  # Méthode speak pour gérer le cas "perform('speak', { message: ... })" côté client
  def speak(data)
    messageable = params[:messageable_type].constantize.find(params[:messageable_id])
    full_name = determine_full_name(connection.current_user)

    message = Message.create!(
      content: data['message'],
      user: connection.current_user,
      messageable: messageable,
      full_name: full_name
    )

    if connection.current_user.role == 'admin' && messageable.is_a?(Employee)
      message.update!(recipient_id: messageable.user_id)
    elsif connection.current_user.role == 'employee'
      admin_user = User.find_by(role: 'admin')
      message.update!(recipient_id: admin_user.id) if admin_user
    end

    Rails.logger.info "Message créé via speak => user_id=#{message.user_id}, recipient_id=#{message.recipient_id}"
    self.class.broadcast_message(message)
  end


  def self.broadcast_read_status(message)
    payload = {
      message_id: message.id,
      messageable_id: message.messageable_id,  # AJOUT
      read_at: message.read_at,
      recipient_id: message.recipient_id
    }
    Rails.logger.debug "CommunicationChannel.broadcast_read_status => #{payload.inspect}"
    ActionCable.server.broadcast("#{message.messageable_type.downcase}_#{message.messageable_id}_channel", payload)
  end



  private

  def determine_full_name(user)
    case user.role
    when 'employee'
      emp = ::Employee.find_by(user_id: user.id)
      emp ? "#{emp.firstname} #{emp.lastname}" : user.email
    when 'customer'
      cli = ::Client.find_by(email: user.email)
      cli ? "#{cli.firstname} #{cli.lastname}" : user.email
    when 'admin'
      emp = ::Employee.find_by(email: user.email)
      emp ? "#{emp.firstname} #{emp.lastname}" : user.email
    else
      user.name rescue user.email
    end
  end
end
