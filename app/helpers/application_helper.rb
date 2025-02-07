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
    mois = {
      "January" => "Janvier", "February" => "Février", "March" => "Mars",
      "April" => "Avril", "May" => "Mai", "June" => "Juin",
      "July" => "Juillet", "August" => "Août", "September" => "Septembre",
      "October" => "Octobre", "November" => "Novembre", "December" => "Décembre"
    }
    "#{mois[date.strftime('%B')]} #{date.strftime('%Y')}"
  end
end
