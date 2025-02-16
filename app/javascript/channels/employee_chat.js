import consumer from "./consumer"

document.addEventListener("DOMContentLoaded", () => {
  console.log("DOM entièrement chargé.");

  // Récupérer les données depuis la vue
  const employeeData = document.getElementById("employee-data");
  const employeeId = employeeData ? employeeData.dataset.employeeId : null;
  const currentUserEmail = employeeData ? employeeData.dataset.currentUserEmail : null;
  console.log("Employee ID :", employeeId);
  console.log("Current user email :", currentUserEmail);

  if (!employeeId || !currentUserEmail) {
    console.error("Les données nécessaires (employeeId ou currentUserEmail) sont manquantes.");
    return;
  }

  // Souscription au canal avec l'ID de l'employé
  const channel = consumer.subscriptions.create(
    { channel: "CommunicationChannel", employee_id: employeeId },
    {
      connected() {
        console.log(`Connecté au canal pour l'employé ${employeeId}`);
      },
      disconnected() {
        console.log("Déconnecté du canal");
      },
      received(data) {
        console.log("Message reçu :", data);
        const messagesContainer = document.getElementById("messages");

        // Créer le conteneur global pour le message
        const container = document.createElement("div");
        container.classList.add("message-container");
        container.classList.add(data.user === currentUserEmail ? "self" : "other");

        // Créer la bulle du message
        const bubble = document.createElement("div");
        bubble.classList.add("message-bubble");
        bubble.textContent = data.message;

        // Créer l'élément pour le timestamp
        const timestamp = document.createElement("div");
        timestamp.classList.add("message-timestamp");
        timestamp.textContent = data.sent_at;

        // Ajouter la bulle et le timestamp dans le conteneur
        container.appendChild(bubble);
        container.appendChild(timestamp);

        // Ajouter le conteneur au chat et faire défiler vers le bas
        messagesContainer.appendChild(container);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
      }
    }
  );

  // Gestion du formulaire d'envoi (envoi avec la touche Entrée)
  const form = document.getElementById("new_message");
  if (form) {
    form.addEventListener("submit", function(event) {
      event.preventDefault();
      console.log("Événement submit déclenché.");

      const input = document.getElementById("message_content");
      const message = input.value.trim();
      console.log("Message à envoyer :", message);

      if (message !== "") {
        channel.perform("speak", { message: message, employee_id: employeeId });
        input.value = "";
      } else {
        console.log("Le message est vide, rien à envoyer.");
      }
    });
  } else {
    console.error("Le formulaire #new_message est introuvable dans le DOM.");
  }
});
