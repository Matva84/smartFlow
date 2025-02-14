class CommunicationChannel < ApplicationCable::Channel
  def subscribed
    if params[:employee_id].present?
      # On diffuse sur un stream dédié à cet employé, par exemple
      stream_from "employee_#{params[:employee_id]}_channel"
    else
      reject
    end
  end

  def speak(data)
    # Vous pouvez ajouter ici des vérifications (par exemple, autoriser uniquement l'admin à envoyer)
    ActionCable.server.broadcast "employee_#{params[:employee_id]}_channel",
      message: data['message'], user: current_user.name
  end
end
