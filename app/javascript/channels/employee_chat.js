import consumer from "./consumer"

document.addEventListener("DOMContentLoaded", () => {
  // Supposons que vous avez une donnée dans le HTML ou utilisez directement @employee.id
  const employeeId = "<%= @employee.id %>";

  // Création de la souscription au canal en passant l'ID de l'employé
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
        const messagesContainer = document.getElementById("messages");
        const messageElement = document.createElement("p");
        messageElement.innerText = `${data.user} : ${data.message}`;
        messagesContainer.appendChild(messageElement);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
      }
    }
  );

  // Attacher le gestionnaire d'événement pour le submit du formulaire
  const form = document.getElementById("new_message");
  form.addEventListener("submit", function(event) {
    event.preventDefault();
    const input = document.getElementById("message_content");
    const message = input.value.trim();
    if (message !== "") {
      channel.perform("speak", { message: message, employee_id: employeeId });
      input.value = "";
    }
  });
});
