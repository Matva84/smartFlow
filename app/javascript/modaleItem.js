document.addEventListener("DOMContentLoaded", function() {
  // Gestion de la modale d'ajout d'un item (unique)
  const openModalItemBtn = document.getElementById("openModalItem");
  const modalItem = document.getElementById("itemModal");
  const closeModalItemBtn = document.querySelector(".close");

  if (openModalItemBtn && modalItem) {
    openModalItemBtn.addEventListener("click", function(event) {
      event.preventDefault();
      modalItem.style.display = "block";
    });
  }
  if (closeModalItemBtn && modalItem) {
    closeModalItemBtn.addEventListener("click", function() {
      modalItem.style.display = "none";
    });
  }
  window.addEventListener("click", function(event) {
    if (event.target === modalItem) {
      modalItem.style.display = "none";
    }
  });

  // Gestion des modales pour l'ajout de matériel (multiples)
  // Sélectionne tous les boutons d'ouverture dont l'id commence par "addMaterialModal-"
  const openMaterialTriggers = document.querySelectorAll("[id^='addMaterialModal-']");
  openMaterialTriggers.forEach(function(trigger) {
    trigger.addEventListener("click", function(event) {
      event.preventDefault();
      // Récupère l'id unique associé (ex: pour "addMaterialModal-17", idSuffix = "17")
      const idSuffix = trigger.id.split("addMaterialModal-")[1];
      const modalMaterial = document.getElementById("itemModal2-" + idSuffix);
      if (modalMaterial) {
        modalMaterial.style.display = "block";
      }
    });
  });

  // Fermer les modales de matériel en cliquant sur la croix (classe "close2")
  const closeMaterialButtons = document.querySelectorAll(".close2");
  closeMaterialButtons.forEach(function(button) {
    button.addEventListener("click", function() {
      const modalMaterial = button.closest(".modal");
      if (modalMaterial) {
        modalMaterial.style.display = "none";
      }
    });
  });

  // Fermer une modale de matériel en cliquant en dehors du contenu
  const materialModals = document.querySelectorAll("[id^='itemModal2-']");
  window.addEventListener("click", function(event) {
    materialModals.forEach(function(modalMaterial) {
      if (event.target === modalMaterial) {
        modalMaterial.style.display = "none";
      }
    });
  });
});
