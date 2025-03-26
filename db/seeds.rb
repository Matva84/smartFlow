require 'date'

# Reset the database (optional)
User.destroy_all
Employee.destroy_all
Client.destroy_all
Project.destroy_all
Event.destroy_all
Setting.destroy_all

# Create an admin user
admin_user = User.create!(
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  role: "admin"
)

employee0 = Employee.create!(
  firstname: "Mat",
  lastname: "VALLEAU",
  address: "123 Rue de l'Université, 91400 Orsay",
  phone: "555-000-233",
  email: admin_user.email,
  group: "GMI",
  position: "Ingénieur",
  hoursalary: 50,
  user: admin_user,
  admin: true
)

puts "✅ Admin created: #{admin_user.email}"

# Créer les employés avec de vraies adresses en France
employees_data = [
  { email: "fabien@example.com", firstname: "Fabien", lastname: "BRIQUEZ", address: "10 Rue de la République, 91400 Orsay", group: "GMI", position: "Ingénieur" },
  { email: "fabrice@example.com", firstname: "Fabrice", lastname: "MARTEAU", address: "15 Rue de l'Église, 91460 Gif-sur-Yvette", group: "GMI", position: "Ingénieur" },
  { email: "olivier@example.com", firstname: "Olivier", lastname: "MARCOUILLE", address: "25 Rue de la Liberté, 94260 Fresnes", group: "GMI", position: "Ingénieur" },
  { email: "romain@example.com", firstname: "Romain", lastname: "BAILLIER", address: "5 Avenue du Général Leclerc, 91940 Les Ulis", group: "GMI", position: "Technicien" },
  { email: "philippe@example.com", firstname: "Philippe", lastname: "BERTEAUD", address: "7 Rue de l'Église, 91530 Arpajon", group: "GAM", position: "Technicien" },
  { email: "anthony@example.com", firstname: "Anthony", lastname: "BERLIOUX", address: "3 Rue des Lilas, 91700 Bures-sur-Yvette", group: "GAM", position: "Ingénieur" }
]

employees = employees_data.map do |emp_data|
  user = User.create!(
    email: emp_data[:email],
    password: "password",
    password_confirmation: "password",
    role: "employee"
  )

  employee = Employee.create!(
    firstname: emp_data[:firstname],
    lastname: emp_data[:lastname],
    address: emp_data[:address],
    phone: "555-000-233",
    email: user.email,
    group: emp_data[:group],
    position: emp_data[:position],
    hoursalary: 50,
    user: user,
    admin: false
  )

  puts "✅ Employee created: #{employee.firstname} #{employee.lastname} (#{employee.email})"
  employee
end

# Créer des clients avec de vraies adresses en France
clients_data = [
  { email: "martine@example.com", firstname: "Martine", lastname: "DOLADILLE", address: "15 Rue de Rivoli, 75001 Paris", rib: "rib1" },
  { email: "michelle@example.com", firstname: "Michèle", lastname: "COLLOT", address: "27 Boulevard Baille, 13001 Marseille", rib: "rib2" },
  { email: "vincent@example.com", firstname: "Vincent", lastname: "LAUNAY", address: "12 Rue de la Monnaie, 35000 Rennes", rib: "rib13" },
  { email: "amelie@example.com", firstname: "Amélie", lastname: "BURBAN", address: "22 Rue de la Paix, 75002 Paris", rib: "rib14" },
  { email: "catherine@example.com", firstname: "Catherine", lastname: "DEGRES", address: "5 Place de la Liberté, 56000 Vannes", rib: "rib14" },
  { email: "violaine@example.com", firstname: "Violaine", lastname: "MAGNEN", address: "18 Avenue de la République, 56500 Séné", rib: "rib14" }
]

clients = clients_data.map do |cli_data|
  user = User.create!(
    email: cli_data[:email],
    password: "password",
    password_confirmation: "password",
    role: "customer"
  )

  client = Client.create!(
    firstname: cli_data[:firstname],
    lastname: cli_data[:lastname],
    address: cli_data[:address],
    phone: "555-000-233",
    email: user.email,
    rib: cli_data[:rib]
  )

  puts "✅ Customer created: #{client.firstname} #{client.lastname} (#{client.email})"
  client
end

# Générer des événements pour les employés sur les deux prochains mois
event_types = ["congé", "télétravail", "heures_supplémentaires"]
statuses = ["approuvé", "en_attente"]

employees.each do |employee|
  taken_dates = [] # Liste des dates déjà utilisées pour cet employé

  5.times do
    begin
      start_date = (Date.today + rand(1..60)) # Date aléatoire dans les 2 prochains mois
    end while start_date.saturday? || start_date.sunday? || taken_dates.include?(start_date) # Éviter week-end et doublons

    part_of_day = ["morning", "afternoon", nil].sample # Demi-journée ou journée entière

    # Si l'événement est sur une demi-journée, la date de début et de fin sont identiques
    end_date = part_of_day.nil? ? (start_date + rand(0..2)) : start_date

    # Vérifier que chaque jour de la plage de dates est disponible et ne tombe pas un week-end
    while end_date.saturday? || end_date.sunday? || taken_dates.include?(end_date)
      end_date -= 1.day
    end

    # Marquer les jours pris pour éviter d'autres événements le même jour
    (start_date..end_date).each { |date| taken_dates << date }

    event_type = event_types.sample
    status = statuses.sample

    Event.create!(
      employee: employee,
      event_type: event_type,
      start_date: start_date,
      end_date: end_date,
      part_of_day: part_of_day,
      status: status,
      overtime_hours: event_type == "heures_supplémentaires" ? rand(1..5) : nil
    )

    puts "Event created: #{event_type} for #{employee.firstname} #{employee.lastname} on #{start_date} (#{part_of_day || 'Journée entière'}) - #{status}"
  end
end

puts "✅ Events generated for the next 2 months!"

# Créer des projets avec des employés et des clients assignés, avec de vraies adresses
projects_data = [
  { name: "Construction d'un immeuble à Paris", address: "15 Rue de la République, 75001 Paris", budget: 1_500_000 },
  { name: "Rénovation d'une maison à Marseille", address: "27 Boulevard Baille, 13001 Marseille", budget: 200_000 },
  { name: "Aménagement d'un parc à Rennes", address: "12 Rue de la Monnaie, 35000 Rennes", budget: 500_000 },
  { name: "Construction d'un complexe sportif à Orsay", address: "5 Avenue du Général Leclerc, 91400 Orsay", budget: 2_000_000 },
  { name: "Modernisation des bureaux à Bures-sur-Yvette", address: "3 Rue des Lilas, 91700 Bures-sur-Yvette", budget: 100_000 },
  { name: "Installation de panneaux solaires à Vannes", address: "5 Place de la Liberté, 56000 Vannes", budget: 300_000 }
]

projects_data.each do |proj_data|
  start_date = Date.today - rand(30..180) # Date de début entre il y a 1 à 6 mois
  end_date = start_date + rand(60..365) # Durée du projet entre 2 mois et 1 an

  project = Project.create!(
    name: proj_data[:name],
    description: "Projet de #{proj_data[:name]} situé à #{proj_data[:address]}.",
    address: proj_data[:address],
    start_at: start_date,
    end_at: end_date,
    totalbudget: proj_data[:budget],
    progression: rand(10..50),
    human_cost: proj_data[:budget] * 0.3,
    material_cost: proj_data[:budget] * 0.2,
    customer_budget: proj_data[:budget] * 1.05,
    total_expenses: proj_data[:budget] * 0.5,
    client: clients.sample,
    employees: employees.sample(rand(3..6))
  )

  puts "Project created: #{project.name} (Client: #{project.client.firstname} #{project.client.lastname})"
end

puts "✅ Projets créés avec succès !"

# Générer des notes de frais pour chaque employé
expense_categories = ["Repas", "Transport", "Hébergement", "Matériel", "Autres"]

employees.each do |employee|
  rand(2..5).times do # Chaque employé a entre 2 et 5 notes de frais
    Expense.create!(
      employee: employee,
      amount: rand(10..300), # Montant entre 10€ et 300€
      date: Faker::Date.between(from: 2.months.ago, to: Date.today), # Date aléatoire sur les 2 derniers mois
      description: "#{expense_categories.sample} professionnel",
      status: "en_attente"
    )
  end
end

puts "✅ Notes de frais générées pour chaque employé avec le statut 'en attente'."

# Paramètres globaux

Setting.create!(key: "company_name", value: true, label: "Nom de la société", value_type: "string")
Setting.create!(key: "company_address", value: true, label: "Addresse de la société", value_type: "string")
Setting.create!(key: "company_siren", value: true, label: "SIREN/SIRET de la société", value_type: "string")
Setting.create!(key: "company_email", value: true, label: "Email", value_type: "string")
Setting.create!(key: "company_phone", value: true, label: "Téléphone", value_type: "string")
Setting.create!(key: "company_contact", value: true, label: "Contact", value_type: "string")
Setting.create!(key: "company_website", value: true, label: "Site web", value_type: "string")

Setting.create!(key: "labor_tva", value: 20.0, label:"TVA sur la main d'oeuvre", value_type: "float")
Setting.create!(key: "material_tva", value: 5.5, label:"TVA sur le matériel", value_type: "float")
Setting.create!(key: "quote_prefix", value: "Relax_", label:"Préfix pour les devis", value_type: "string")
Setting.create!(key: "expenses_enabled", value: true, label: "Activer les notes de frais", value_type: "boolean")
Setting.create!(key: "company_logo",label: "Logo de la société",value_type: "file", value: "")

puts "✅ Seeding completed successfully!"
