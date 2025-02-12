class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  def index
    @clients = Client.all
  end

  def show; end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to @client, notice: "Client créé avec succès."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @client.update(client_params)
      redirect_to @client, notice: "Client mis à jour avec succès."
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_path, notice: "Client supprimé avec succès."
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:firstname, :lastname, :address, :phone, :email, :rib)
  end
end
