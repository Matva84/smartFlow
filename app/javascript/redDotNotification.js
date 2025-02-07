document.addEventListener("DOMContentLoaded", function() {
  //console.log("Script chargé et DOM prêt");

  const employeeMenuItem = Array.from(document.querySelectorAll('.btn-lat-menu strong')).find(item => item.textContent.trim() === "Employés");
  //console.log("Element du menu employé trouvé :", employeeMenuItem);

  fetch('/events/pending_count')
    .then(response => {
      //console.log("Réponse de la requête fetch reçue :", response);
      if (!response.ok) {
        throw new Error("Réponse réseau non valide");
      }
      return response.json();
    })
    .then(data => {
      //console.log("Données reçues :", data);
      if (data.pending_count > 0 && employeeMenuItem) {
        const notificationDot = document.createElement('span');
        notificationDot.style.backgroundColor = 'red';
        notificationDot.style.width = '10px';
        notificationDot.style.height = '10px';
        notificationDot.style.borderRadius = '50%';
        notificationDot.style.display = 'inline-block';
        notificationDot.style.marginLeft = '5px';
        employeeMenuItem.appendChild(notificationDot);
        //console.log("Point de notification ajouté");
      } else {
        //console.log("Aucun événement en attente ou élément du menu introuvable");
      }
    })
    .catch(error => console.error('Erreur lors de la vérification des événements en attente:', error));
});
