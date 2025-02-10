document.addEventListener("DOMContentLoaded", function() {
  //console.log("Script chargé et DOM prêt");

  // Vérifier si l'utilisateur est connecté et récupérer son rôle
  const userLoggedIn = document.querySelector("meta[name='user-logged-in']").content === "true";
  const userRole = document.querySelector("meta[name='user-role']").content;

  if (!userLoggedIn || userRole !== "admin") {
    //console.log("Utilisateur non admin ou non connecté, suppression de la notification et des demandes en attente.");

    // Cacher la notification
    const employeeMenuItem = document.querySelector('.btn-lat-menu strong');
    if (employeeMenuItem) {
      employeeMenuItem.innerHTML = employeeMenuItem.textContent.trim(); // Supprime le point rouge s'il existe
    }

    // Cacher la section des demandes en attente
    const pendingRequestsSection = document.querySelector(".halfwidth.formdiv.asks");
    if (pendingRequestsSection) {
      pendingRequestsSection.style.display = "none";
    }

    return; // Stoppe l'exécution du reste du script
  }

  // Si l'utilisateur est admin, continuer à afficher la notification et les demandes
  const employeeMenuItem = Array.from(document.querySelectorAll('.btn-lat-menu strong'))
    .find(item => item.textContent.trim() === "Employés");

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
        //console.log("Point de notification ajouté avec compteur");
      }
    })
    .catch(error => console.error('Erreur lors de la vérification des événements en attente:', error));
});
