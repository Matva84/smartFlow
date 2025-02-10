module ApplicationHelper
  def translate_period(period)
    {
      "last_year" => "l'année passée",
      "this_year" => "cette année",
      "this_month" => "ce mois-ci",
      "last_month" => "le mois dernier"
    }[period]
  end
  def mois_francais(date)
    I18n.l(date, format: "%B %Y")
  end
    def user_initials(user)
      return "" unless user&.employee
      "#{user.employee.firstname.first.upcase}#{user.employee.lastname.first.upcase}"
    end

    def random_pastel_color
      # Générer une couleur pastel aléatoire en modifiant la saturation et la luminosité
      hue = rand(0..360) # Teinte aléatoire
      "hsl(#{hue}, 70%, 80%)" # 70% de saturation, 80% de luminosité pour un effet pastel
    end

end
