import consumer from "./consumer"

document.addEventListener("DOMContentLoaded", () => {
  console.log("DOM entièrement chargé!");
  const chatData = document.getElementById("chat-data");
  const messageableType = chatData ? chatData.dataset.messageableType : null;
  const messageableId = chatData ? chatData.dataset.messageableId : null;
  const currentUserEmail = chatData ? chatData.dataset.currentUserEmail : null;

  if (!messageableType || !messageableId || !currentUserEmail) {
    console.error("Données de chat manquantes.");
    return;
  }

  const channel = consumer.subscriptions.create(
    { channel: "CommunicationChannel", messageable_type: messageableType, messageable_id: messageableId },
    {
      connected() {
        console.log(`Connecté au canal ${messageableType}_${messageableId}`);
      },
      disconnected() {
        console.log("Déconnecté du canal");
      },
      received(data) {
        console.log("Message reçu :", data);
        const messagesContainer = document.getElementById("messages");

        const container = document.createElement("div");
        container.classList.add("message-container");
        container.classList.add(data.user === currentUserEmail ? "self" : "other");

        const bubble = document.createElement("div");
        bubble.classList.add("message-bubble");
        bubble.textContent = data.message;

        // Créer l'élément pour le timestamp et y inclure le nom complet
        const timestamp = document.createElement("div");
        timestamp.classList.add("message-timestamp");
        // Afficher "Prénom Nom - Le dd/mm/yyyy à hh:mm"
        timestamp.textContent = `${data.full_name} - ${data.sent_at}`;

        container.appendChild(bubble);
        container.appendChild(timestamp);

        messagesContainer.appendChild(container);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
      }

    }
  );

  const form = document.getElementById("new_message");
  if (form) {
    form.addEventListener("submit", event => {
      event.preventDefault();
      const input = document.getElementById("message_content");
      const message = input.value.trim();
      if (message !== "") {
        channel.perform("speak", { message: message });
        input.value = "";
      }
    });
  }
});
