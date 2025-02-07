document.addEventListener("DOMContentLoaded", function() {
  const eventTypeSelect = document.querySelector('#event_event_type');
  const overtimeField = document.querySelector('#overtime_hours_field');
  const endDateField = document.getElementById("end_date_field");
  const startDateField = document.getElementById("start_date_field");

  eventTypeSelect.addEventListener('change', function() {
    if (eventTypeSelect.value === 'heures_supplémentaires') {
      overtimeField.style.display = 'block';
      endDateField.style.display = 'none';
      endDateField.value = startDateField.value; // Forcer la date de fin à être identique à la date de début
    } else {
      overtimeField.style.display = 'none';
      endDateField.style.display = 'block';
    }
  });
});
