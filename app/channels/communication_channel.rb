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

    # Diffuser sur le canal
    channel_name = "#{message.messageable_type.downcase}_#{message.messageable_id}_channel"
    ActionCable.server.broadcast(channel_name, payload)
  end

  # Méthode speak pour gérer le cas "perform('speak', { message: ... })" côté client
  def speak(data)
    messageable = params[:messageable_type].constantize.find(params[:messageable_id])
    full_name = determine_full_name(connection.current_user)
    # Créer le message (uniquement texte, par exemple)
    message = Message.create!(
      content: data['message'],
      user: connection.current_user,
      messageable: messageable,
      full_name: full_name
    )
    if messageable.is_a?(Employee)
      message.update!(recipient_id: messageable.user_id)
    end
    Rails.logger.info "Message créé via speak => #{message.inspect}"
    # Diffuser via la méthode de classe
    self.class.broadcast_message(message)
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
