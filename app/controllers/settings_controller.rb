class SettingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @settings = Setting.all
  end

  # Action pour mettre à jour plusieurs settings d'un coup
  def update_multiple
    params[:settings].each do |id, new_value|
      setting = Setting.find(id)
      # Pour les booléens, le champ renvoie "0" ou "1"
      if setting.value_type == "boolean"
        # On convertit la valeur reçue en booléen
        setting.update(value: ActiveModel::Type::Boolean.new.cast(new_value).to_s)
      else
        setting.update(value: new_value)
      end
    end
    redirect_to settings_path, notice: "Paramètres mis à jour."
  end

  def edit
    @setting = Setting.find(params[:id])
    @value_types = ['string', 'float', 'boolean']
  end

  def update
    @setting = Setting.find(params[:id])
    if @setting.update(setting_params)
      redirect_to settings_path, notice: "Paramètre mis à jour avec succès."
    else
      render :edit
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:value)
  end
end
