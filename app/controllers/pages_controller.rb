class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:home]

  def home
    # Page accessible sans authentification
  end

  def about
    # Nécessite une authentification
  end
end
