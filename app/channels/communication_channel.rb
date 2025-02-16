class CommunicationChannel < ApplicationCable::Channel
  def subscribed
    if params[:messageable_type].present? && params[:messageable_id].present?
      stream_from "#{params[:messageable_type].downcase}_#{params[:messageable_id]}_channel"
    else
      reject
    end
  end

  def speak(data)
    messageable = params[:messageable_type].constantize.find(params[:messageable_id])

    # Déterminer le nom complet en fonction du rôle de l'utilisateur connecté
    full_name =
      if connection.current_user.role == 'employee'
        employee_record = ::Employee.find_by(user_id: connection.current_user.id)
        employee_record ? "#{employee_record.firstname} #{employee_record.lastname}" : connection.current_user.email
      elsif connection.current_user.role == 'customer'
        client_record = ::Client.find_by(email: connection.current_user.email)
        client_record ? "#{client_record.firstname} #{client_record.lastname}" : connection.current_user.email
      elsif connection.current_user.role == 'admin'
        employee_record = ::Employee.find_by(email: connection.current_user.email)
        employee_record ? "#{employee_record.firstname} #{employee_record.lastname}" : connection.current_user.email
      else
        connection.current_user.name rescue connection.current_user.email
      end

    # Crée le message en incluant le full_name
    message = Message.create!(
      content: data['message'],
      user: connection.current_user,
      messageable: messageable,
      full_name: full_name
    )
    Rails.logger.info "Message sauvegardé : #{message.inspect}"

    payload = {
      message: message.content,
      user: connection.current_user.email,
      full_name: message.full_name,  # On utilise ici la valeur persistée
      sent_at: message.created_at.strftime("%d/%m à %H:%M")
    }
    ActionCable.server.broadcast("#{params[:messageable_type].downcase}_#{params[:messageable_id]}_channel", payload)
  end
end
