namespace :expenses do
  desc "Créer automatiquement les notes de frais fixes au début de chaque mois"
  task create_fixed_expenses: :environment do
    puts "📅 Génération des notes de frais fixes pour le mois en cours..."
    Expense.generate_monthly_fixed_expenses
    puts "✅ Notes de frais fixes créées avec succès !"
  end
end
