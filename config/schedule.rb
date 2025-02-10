every :month, at: '12:00am' do
  rake "expenses:create_fixed_expenses"
end
