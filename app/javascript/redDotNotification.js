document.addEventListener("DOMContentLoaded", function() {
  //console.log("Script chargé et DOM prêt");

  const employeeMenuItem = Array.from(document.querySelectorAll('.btn-lat-menu strong')).find(item => item.textContent.trim() === "Employés");
  //console.log("Element du menu employé trouvé :", employeeMenuItem);

  fetch('/events/pending_count')
  .then(response => {
    console.log("Réponse de la requête fetch reçue :", response);
    if (!response.ok) {
      throw new Error("Réponse réseau non valide");
    }
    return response.json();
  })
  .then(data => {
    console.log("Données reçues :", data);
    if (data.pending_count > 0 && employeeMenuItem) {
      const notificationDot = document.createElement('span');
      notificationDot.style.backgroundColor = 'red';
      notificationDot.style.color = 'white';
      notificationDot.style.width = '20px';
      notificationDot.style.height = '20px';
      notificationDot.style.borderRadius = '50%';
      notificationDot.style.display = 'inline-flex';
      notificationDot.style.alignItems = 'center';
      notificationDot.style.justifyContent = 'center';
      notificationDot.style.marginLeft = '0px';
      notificationDot.style.position = 'relative';
      notificationDot.style.top = '-10px';
      notificationDot.style.fontSize = '8px';
      notificationDot.textContent = data.pending_count;
      employeeMenuItem.appendChild(notificationDot);
      console.log("Point de notification ajouté avec compteur");
    }
  })
  .catch(error => console.error('Erreur lors de la vérification des événements en attente:', error));

});
