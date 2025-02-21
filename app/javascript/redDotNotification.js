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

    // Cacher toutes les sections des demandes en attente
const pendingRequestsSections = document.querySelectorAll(".halfwidth.formdiv.toBeHiddenForEmployees");
pendingRequestsSections.forEach(section => {
  section.style.display = "none";
});


    return; // Stoppe l'exécution du reste du script
  }

  // Si l'utilisateur est admin, continuer à afficher la notification et les demandes
  const employeeMenuItem = Array.from(document.querySelectorAll('.btn-lat-menu strong'))
    .find(item => item.textContent.trim() === "Employés");

  //console.log("Element du menu employé trouvé :", employeeMenuItem);

  // Effectuer les deux fetch en parallèle
  Promise.all([
    fetch('/events/pending_count')
      .then(response => {
        //console.log("📡 Réponse brute pour events:", response);
        if (!response.ok) {
          throw new Error("Erreur HTTP : " + response.status);
        }
        return response.json();
      }),

    fetch('/expenses/pending_count2')
      .then(response => {
        //console.log("📡 Réponse brute pour expenses:", response);
        if (!response.ok) {
          throw new Error("Erreur HTTP : " + response.status);
        }
        return response.json();
      })
  ])
  .then(([eventsData, expensesData]) => {
    //console.log("✅ Données reçues pour events et expenses :", eventsData, expensesData);

    const eventsCount = parseInt(eventsData.pending_count, 10) || 0;
    const expensesCount = parseInt(expensesData.pending_expenses_count || 0, 10);
    const totalCount = eventsCount + expensesCount;

    //console.log("📊 Nombre total d'événements et de dépenses en attente :", totalCount);

    if (totalCount > 0 && employeeMenuItem) {
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
      notificationDot.textContent = totalCount;
      employeeMenuItem.appendChild(notificationDot);
    }
  })
  .catch(error => console.error('❌ Erreur lors de la vérification des événements ou des dépenses en attente:', error));

});
