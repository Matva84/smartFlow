document.addEventListener("DOMContentLoaded", function() {
  //console.log("Script chargé et DOM prêt");

  const employeeMenuItem = Array.from(document.querySelectorAll('.btn-lat-menu strong')).find(item => item.textContent.trim() === "Employés");
  //console.log("Element du menu employé trouvé :", employeeMenuItem);

  fetch('/events/approved_overtime_hours')
    .then(response => response.json())
    .then(data => {
      console.log("Total des heures supplémentaires validées :", data.total_overtime_hours);
      if (data.total_overtime_hours > 0 && employeeMenuItem) {
        const overtimeCounter = document.createElement('span');
        overtimeCounter.textContent = ` (${data.total_overtime_hours}h) `;
        overtimeCounter.style.color = 'blue';
        overtimeCounter.style.fontWeight = 'bold';
        overtimeCounter.style.marginLeft = '5px';
        employeeMenuItem.appendChild(overtimeCounter);
      }
    })
    .catch(error => console.error('Erreur lors de la récupération des heures supplémentaires:', error));

  const startDateField = document.getElementById('start_date_field');
  const endDateField = document.getElementById('end_date_field');
  const eventTypeField = document.getElementById('event_event_type');
  const partOfDayFields = document.getElementById('part_of_day_fields');

  function toggleFields() {
    const startDate = new Date(startDateField.value);
    const eventType = eventTypeField.value;

    if (eventType === 'heures_supplémentaires') {
      endDateField.style.display = "none";
      endDateField.value = startDateField.value;
    } else {
      endDateField.style.display = "block";
    }
  }

  function isPastDate(date) {
    return date < new Date().setHours(0, 0, 0, 0);
  }

  function isWeekendOrHoliday(date) {
    return date.getDay() === 0 || date.getDay() === 6; // Ajouter les jours fériés si nécessaire
  }

  function validateEventRestrictions() {
    const startDate = new Date(startDateField.value);
    const eventType = eventTypeField.value;
    const userRole = document.body.dataset.userRole; // Supposons que le rôle est stocké dans l'attribut dataset

    if (eventType === 'arrêt_maladie' && userRole !== 'admin') {
      alert("Seul un administrateur peut poser un arrêt de travail.");
      return false;
    }

    if ((eventType === 'télétravail' || eventType === 'heures_supplémentaires') && isPastDate(startDate) && userRole !== 'admin') {
      alert("Impossible de poser un télétravail ou des heures supplémentaires pour une date passée.");
      return false;
    }

    if ((eventType === 'télétravail' || eventType === 'heures_supplémentaires') && isWeekendOrHoliday(startDate)) {
      alert("Impossible de poser un télétravail ou des heures supplémentaires un jour férié ou un week-end.");
      return false;
    }

    if (eventType === 'heures_supplémentaires') {
      const oneWeekAgo = new Date();
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
      if (startDate < oneWeekAgo) {
        alert("Impossible de déclarer des heures supplémentaires au-delà d'une semaine en arrière.");
        return false;
      }
    }

    return true;
  }

  function togglePartOfDayFields() {
    const startDate = new Date(startDateField.value);
    const endDate = new Date(endDateField.value);
    const eventType = eventTypeField.value;

    if (startDate && endDate && startDate.getTime() === endDate.getTime() && eventType !== 'heures_supplémentaires') {
      partOfDayFields.style.display = "block";
    } else {
      partOfDayFields.style.display = "none";
    }
  }

  function validateOvertime() {
    const startDate = new Date(startDateField.value);
    const eventType = eventTypeField.value;

    if (eventType === 'heures_supplémentaires') {
      if (startDate.getDay() === 0 || startDate.getDay() === 6) {
        alert("Impossible de poser des heures supplémentaires un week-end.");
        return false;
      }

      fetch(`/employees/check_availability?date=${startDate.toISOString().split('T')[0]}`)
        .then(response => response.json())
        .then(data => {
          if (!data.available) {
            alert("Impossible de poser des heures supplémentaires sur un jour non travaillé ou déjà pris.");
            return false;
          }
        })
        .catch(error => console.error('Erreur lors de la vérification de la disponibilité:', error));
    }
  }

  startDateField.addEventListener('change', () => {
    toggleFields();
    if (!validateEventRestrictions()) {
      startDateField.value = "";
    }
    if (eventTypeField.value === 'heures_supplémentaires') {
      validateOvertime();
    } else {
      togglePartOfDayFields();
    }
  });

  endDateField.addEventListener('change', () => {
    togglePartOfDayFields();
  });

  eventTypeField.addEventListener('change', () => {
    toggleFields();
    validateEventRestrictions();
    validateOvertime();
    togglePartOfDayFields();
  });
});
