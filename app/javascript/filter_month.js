document.addEventListener("DOMContentLoaded", () => {
  const resetButton = document.getElementById("reset-dates");
  const startDateField = document.getElementById("start_date_field");
  const endDateField = document.getElementById("end_date_field");

  resetButton.addEventListener("click", () => {
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);

    startDateField.value = firstDay.toISOString().split("T")[0];
    endDateField.value = lastDay.toISOString().split("T")[0];
  });
});
