document.addEventListener("DOMContentLoaded", function() {
  // Sélectionne les éléments de la modale
  const modal = document.getElementById("eventModal");
  const openModalBtn = document.getElementById("openModal");
  const closeModalBtn = document.querySelector(".close");

  // Ouvrir la modale au clic sur "Ajouter un événement"
  openModalBtn.addEventListener("click", function(event) {
    event.preventDefault(); // Empêche la redirection du lien
    modal.style.display = "block";
  });

  // Fermer la modale au clic sur la croix
  closeModalBtn.addEventListener("click", function() {
    modal.style.display = "none";
  });

  // Fermer la modale au clic en dehors du contenu
  window.addEventListener("click", function(event) {
    if (event.target === modal) {
      modal.style.display = "none";
    }
  });
});
