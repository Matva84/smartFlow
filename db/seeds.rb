# Reset the database (optional)
User.destroy_all
Employee.destroy_all

# Create an admin user
admin_user = User.create!(
  email: "admin@example.com",
  password: "password",
  password_confirmation: "password",
  role: "admin"
)
puts "Admin created: #{admin_user.email}"

# Create multiple employees
#10.times do |i|
#  user = User.create!(
#    email: "employee#{i + 1}@example.com",
#    password: "password",
#    password_confirmation: "password",
#    role: "employee"
#  )

#  employee = Employee.create!(
#    firstname: "First#{i + 1}",
#    lastname: "Last#{i + 1}",
#    address: "123 Street #{i + 1}, City",
#    phone: "555-000-#{i + 1}",
#    email: user.email,
#    group: "Group#{(i % 3) + 1}",
#    position: "Position#{(i % 5) + 1}",
#    hoursalary: rand(15.0..30.0).round(2),
#    user: user
#  )
#  puts "Employee created: #{employee.firstname} #{employee.lastname} (#{employee.email})"
#end

user1 = User.create!(email: "fabien@example.com",password: "password",password_confirmation: "password",role: "employee")
employee1 = Employee.create!(firstname: "Fabien",lastname: "BRIQUEZ",address: "Orsay",phone: "555-000-233",email: user1.email,group: "GMI",position: "Ingénieur",hoursalary: 50,user: user1)
puts "Employee created: #{employee1.firstname} #{employee1.lastname} (#{employee1.email})"
user2 = User.create!(email: "fabrice@example.com",password: "password",password_confirmation: "password",role: "employee")
employee2 = Employee.create!(firstname: "Fabrice",lastname: "MARTEAU",address: "Gif sur Yvette",phone: "555-000-233",email: user2.email,group: "GMI",position: "Ingénieur",hoursalary: 50,user: user2)
puts "Employee created: #{employee2.firstname} #{employee2.lastname} (#{employee2.email})"
user3 = User.create!(email: "olivier@example.com",password: "password",password_confirmation: "password",role: "employee")
employee3 = Employee.create!(firstname: "Olivier",lastname: "MARCOUILLE",address: "Fresnes",phone: "555-000-233",email: user3.email,group: "GMI",position: "Ingénieur",hoursalary: 50,user: user3)
puts "Employee created: #{employee3.firstname} #{employee3.lastname} (#{employee3.email})"
user4 = User.create!(email: "romain@example.com",password: "password",password_confirmation: "password",role: "employee")
employee4 = Employee.create!(firstname: "Romain",lastname: "BAILLIER",address: "Les Ulis",phone: "555-000-233",email: user4.email,group: "GMI",position: "Technicien",hoursalary: 50,user: user4)
puts "Employee created: #{employee4.firstname} #{employee4.lastname} (#{employee4.email})"
user5 = User.create!(email: "philippe@example.com",password: "password",password_confirmation: "password",role: "employee")
employee5 = Employee.create!(firstname: "Philippe",lastname: "BERTEAUD",address: "Arpajeon",phone: "555-000-233",email: user5.email,group: "GAM",position: "Technicien",hoursalary: 50,user: user5)
puts "Employee created: #{employee5.firstname} #{employee5.lastname} (#{employee5.email})"
user6 = User.create!(email: "anthony@example.com",password: "password",password_confirmation: "password",role: "employee")
employee6 = Employee.create!(firstname: "Anthony",lastname: "BERLIOUX",address: "Bures sur Yvette",phone: "555-000-233",email: user6.email,group: "GAM",position: "Ingénieur",hoursalary: 50,user: user6)
puts "Employee created: #{employee6.firstname} #{employee6.lastname} (#{employee6.email})"

# Create multiple customers
#10.times do |i|
#  user = User.create!(
#    email: "customer#{i + 1}@example.com",
#    password: "password",
#    password_confirmation: "password",
#    role: "customer"
#  )

#  client = Client.create!(
#    firstname: "First#{i + 1}",
#    lastname: "Last#{i + 1}",
#    address: "123 Street #{i + 1}, City",
#    phone: "555-000-#{i + 1}",
#    email: user.email,
#    rib: "rib#{(i % 3) + 1}"
#  )
#  puts "Client created: #{client.firstname} #{client.lastname} (#{client.email})"
#end

user7 = User.create!(email: "martine@example.com",password: "password",password_confirmation: "password",role: "customer")
employee7 = Client.create!(firstname: "Martine",lastname: "DOLADILLE",address: "Paris",phone: "555-000-233",email: user7.email,rib: "rib1")
puts "Customer created: #{employee7.firstname} #{employee7.lastname} (#{employee7.email})"
user8 = User.create!(email: "michelle@example.com",password: "password",password_confirmation: "password",role: "customer")
employee8 = Client.create!(firstname: "Michèle",lastname: "COLLOT",address: "Marseille",phone: "555-000-233",email: user8.email,rib: "rib2")
puts "Customer created: #{employee8.firstname} #{employee8.lastname} (#{employee8.email})"
user9 = User.create!(email: "vincent@example.com",password: "password",password_confirmation: "password",role: "customer")
employee9 = Client.create!(firstname: "Vincent",lastname: "LAUNAY",address: "Rennes",phone: "555-000-233",email: user9.email,rib: "rib13")
puts "Customer created: #{employee9.firstname} #{employee9.lastname} (#{employee9.email})"
user10 = User.create!(email: "amelie@example.com",password: "password",password_confirmation: "password",role: "customer")
employee10 = Client.create!(firstname: "Amélie",lastname: "BURBAN",address: "Paris",phone: "555-000-233",email: user10.email,rib: "rib14")
puts "Customer created: #{employee10.firstname} #{employee10.lastname} (#{employee10.email})"
user11 = User.create!(email: "catherine@example.com",password: "password",password_confirmation: "password",role: "customer")
employee11 = Client.create!(firstname: "Catherine",lastname: "DEGRES",address: "Vannes",phone: "555-000-233",email: user11.email,rib: "rib14")
puts "Customer created: #{employee11.firstname} #{employee11.lastname} (#{employee11.email})"
user12 = User.create!(email: "violaine@example.com",password: "password",password_confirmation: "password",role: "customer")
employee12 = Client.create!(firstname: "Violaine",lastname: "MAGNEN",address: "Séné",phone: "555-000-233",email: user12.email,rib: "rib14")
puts "Customer created: #{employee12.firstname} #{employee12.lastname} (#{employee12.email})"

# Assurez-vous que les employés et les clients existent déjà
clients = Client.all
employees = Employee.all

if clients.size < 6 || employees.size < 6
  puts "Erreur : Assurez-vous d'avoir au moins 6 clients et 6 employés avant de créer des projets."
  exit
end

# Créer des projets réalistes
projects = [
  {
    name: "Construction d'un immeuble à Paris",
    description: "Un projet de construction pour un immeuble résidentiel de 10 étages.",
    address: "15 Rue Lafayette, Paris",
    latitude: 48.8753,
    longitude: 2.3438,
    start_at: Date.today - 6.months,
    end_at: Date.today + 12.months,
    totalbudget: 1_500_000,
    progression: 20,
    human_cost: 400_000,
    material_cost: 300_000,
    customer_budget: 1_600_000,
    total_expenses: 700_000,
    client: clients.sample,
    employees: employees.sample(4)
  },
  {
    name: "Rénovation d'une maison à Marseille",
    description: "Rénovation complète d'une maison ancienne, incluant plomberie et électricité.",
    address: "32 Avenue du Prado, Marseille",
    latitude: 43.2804,
    longitude: 5.3961,
    start_at: Date.today - 3.months,
    end_at: Date.today + 6.months,
    totalbudget: 200_000,
    progression: 50,
    human_cost: 50_000,
    material_cost: 80_000,
    customer_budget: 210_000,
    total_expenses: 130_000,
    client: clients.sample,
    employees: employees.sample(3)
  },
  {
    name: "Aménagement d'un parc à Rennes",
    description: "Création d'espaces verts et aménagement paysager dans un parc public.",
    address: "10 Place de la Mairie, Rennes",
    latitude: 48.112,
    longitude: -1.6778,
    start_at: Date.today - 1.month,
    end_at: Date.today + 8.months,
    totalbudget: 500_000,
    progression: 10,
    human_cost: 120_000,
    material_cost: 100_000,
    customer_budget: 520_000,
    total_expenses: 220_000,
    client: clients.sample,
    employees: employees.sample(5)
  },
  {
    name: "Construction d'un complexe sportif à Orsay",
    description: "Construction d'une piscine et d'un gymnase dans un complexe sportif moderne.",
    address: "18 Avenue des Sciences, Orsay",
    latitude: 48.6973,
    longitude: 2.1734,
    start_at: Date.today - 2.months,
    end_at: Date.today + 10.months,
    totalbudget: 2_000_000,
    progression: 15,
    human_cost: 500_000,
    material_cost: 700_000,
    customer_budget: 2_100_000,
    total_expenses: 1_200_000,
    client: clients.sample,
    employees: employees.sample(6)
  },
  {
    name: "Modernisation des bureaux à Bures-sur-Yvette",
    description: "Modernisation des installations électriques et des réseaux informatiques.",
    address: "5 Rue des Ecoles, Bures-sur-Yvette",
    latitude: 48.695,
    longitude: 2.1703,
    start_at: Date.today - 1.week,
    end_at: Date.today + 2.months,
    totalbudget: 100_000,
    progression: 5,
    human_cost: 20_000,
    material_cost: 30_000,
    customer_budget: 110_000,
    total_expenses: 50_000,
    client: clients.sample,
    employees: employees.sample(3)
  },
  {
    name: "Installation de panneaux solaires à Vannes",
    description: "Installation de panneaux solaires sur un ensemble de bâtiments résidentiels.",
    address: "12 Rue du Port, Vannes",
    latitude: 47.657,
    longitude: -2.7611,
    start_at: Date.today - 2.weeks,
    end_at: Date.today + 4.months,
    totalbudget: 300_000,
    progression: 25,
    human_cost: 50_000,
    material_cost: 100_000,
    customer_budget: 310_000,
    total_expenses: 150_000,
    client: clients.sample,
    employees: employees.sample(4)
  }
]

projects.each do |project_data|
  project = Project.create!(project_data)
  puts "Project created: #{project.name} (Client: #{project.client.firstname} #{project.client.lastname})"
end

puts "6 projets créés avec succès !"

Setting.create(key: "labor_tva", value: "20") # TVA sur la main-d'œuvre en %
Setting.create(key: "material_tva", value: "5.5") # TVA sur le matériel en %
Setting.create(key: "quote_prefix", value: "Devis_") # Préfixe pour les devis

puts "Seeding completed successfully!"
