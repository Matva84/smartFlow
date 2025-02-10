module EmployeesHelper
  def cell_style(employee, event, date, part_of_day)
    return "background-color: gray; color: white; font-weight: bold;" if employee.default_days_off&.include?(date.wday)

    if event.present?
      case event.event_type
      when "arrêt_maladie"
        return "background-color: var(--sick-color); color: white; font-weight: bold;" unless event.part_of_day == (part_of_day == 'morning' ? 'afternoon' : 'morning')
      when "télétravail"
        return "background-color: var(--remote-color); color: white; font-weight: bold;" unless event.part_of_day == (part_of_day == 'morning' ? 'afternoon' : 'morning')
      when "congé"
        return "background-color: var(--holiday-color); color: white; font-weight: bold;" unless event.part_of_day == (part_of_day == 'morning' ? 'afternoon' : 'morning')
      end
    end

    "background-color: white; color: black;"
  end
end
