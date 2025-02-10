document.addEventListener("DOMContentLoaded", function() {
  //console.log("DOM entièrement chargé, script de la modale chargé.");

  // Sélection des éléments de la modale des notes de frais
  const modal = document.getElementById("expenseModal");
  const openModalBtn = document.getElementById("openExpenseModal");
  const closeModalBtn = modal ? modal.querySelector(".close") : null;

  // Log des éléments trouvés
  //console.log("Élément modal:", modal);
  //console.log("Élément bouton ouverture:", openModalBtn);
  //console.log("Élément bouton fermeture:", closeModalBtn);

  // Vérifie que tous les éléments nécessaires existent
  if (!modal) {
    console.error("❌ ERREUR : L'élément de la modale 'expenseModal' n'a pas été trouvé !");
    return;
  }
  if (!openModalBtn) {
    console.error("❌ ERREUR : Le bouton 'openExpenseModal' n'a pas été trouvé !");
    return;
  }
  if (!closeModalBtn) {
    console.error("❌ ERREUR : Le bouton de fermeture dans la modale n'a pas été trouvé !");
    return;
  }

  // Ouvrir la modale au clic sur "Ajouter une note de frais"
  openModalBtn.addEventListener("click", function(event) {
    event.preventDefault();
    //console.log("✅ Clic détecté sur le bouton d'ouverture.");
    modal.style.display = "block";
    //console.log("✅ La modale devrait maintenant être visible.");
  });

  // Fermer la modale au clic sur la croix
  closeModalBtn.addEventListener("click", function() {
    //console.log("✅ Clic détecté sur le bouton de fermeture.");
    modal.style.display = "none";
    //console.log("✅ La modale est maintenant cachée.");
  });

  // Fermer la modale au clic en dehors du contenu
  window.addEventListener("click", function(event) {
    if (event.target === modal) {
      //console.log("✅ Clic détecté en dehors de la modale, fermeture en cours.");
      modal.style.display = "none";
      //console.log("✅ La modale est maintenant cachée.");
    }
  });
});
