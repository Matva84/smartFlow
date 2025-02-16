// Délégation d'événement sur le document pour capter les clics sur le bouton "Nouvelle catégorie"
document.addEventListener("click", function(event) {
  if (event.target && event.target.id === "new-category-button") {
    console.log("[DEBUG] Bouton 'Nouvelle catégorie' cliqué via délégation.");
    var newCategory = prompt("Entrez le nom de la nouvelle catégorie :");
    console.log("[DEBUG] Nouvelle catégorie saisie:", newCategory);
    if (newCategory) {
      // On recherche le select dans le conteneur de la modale
      var modalContent = event.target.closest('.modal-content');
      if (modalContent) {
        var select = modalContent.querySelector('#category-select');
        if (select) {
          console.log("[DEBUG] Element select trouvé via délégation.");
          // Vérifier si la catégorie existe déjà (insensible à la casse et aux espaces)
          var exists = Array.from(select.options).some(function(option) {
            return option.value.trim().toLowerCase() === newCategory.trim().toLowerCase();
          });
          console.log("[DEBUG] La catégorie existe déjà ?", exists);
          if (!exists) {
            var option = document.createElement("option");
            option.text = newCategory;
            option.value = newCategory;
            select.add(option);
            console.log("[DEBUG] Nouvelle option ajoutée :", newCategory);
          } else {
            console.log("[DEBUG] La catégorie existe déjà, aucun ajout.");
          }
          // Mettre à jour la sélection dans le select
          select.value = newCategory;
          console.log("[DEBUG] Nouvelle catégorie sélectionnée :", select.value);
        } else {
          console.error("[ERROR] Element select non trouvé via délégation!");
        }
      } else {
        console.error("[ERROR] Conteneur .modal-content non trouvé!");
      }
    } else {
      console.log("[DEBUG] Aucune catégorie saisie.");
    }
  }
});
