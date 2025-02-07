document.addEventListener("DOMContentLoaded", () => {
  const checkboxes = document.querySelectorAll('input[type="checkbox"][id^="employee_"]');

  checkboxes.forEach((checkbox) => {
    console.log(checkbox);
    checkbox.addEventListener("change", (event) => {
      const label = document.querySelector(`label[for="${checkbox.id}"]`);
      if (event.target.checked) {
        label.style.fontWeight = "bold";
        label.style.color = "green";
      } else {
        label.style.fontWeight = "normal";
        label.style.color = "black";
      }
    });
  });
});
