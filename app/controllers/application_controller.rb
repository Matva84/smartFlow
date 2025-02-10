class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_avatar_color, if: :user_signed_in? # ✅ Correct

  private

  def set_avatar_color
    session[:avatar_color] ||= generate_pastel_color
  end

  def generate_pastel_color
    hue = rand(0..360) # Génère une teinte aléatoire
    "hsl(#{hue}, 70%, 80%)" # Saturation et luminosité pour effet pastel
  end
end
