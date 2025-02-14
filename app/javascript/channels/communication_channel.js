import consumer from "./consumer"

const communicationChannel = consumer.subscriptions.create({ channel: "CommunicationChannel" }, {
  connected() {
    // Appelé lorsque la connexion est établie.
    console.log("Connecté à CommunicationChannel");
  },

  disconnected() {
    // Appelé lorsque la connexion est terminée.
  },

  received(data) {
    // Appelé à la réception de données (messages) du serveur.
    console.log("Message reçu :", data);
    // Par exemple, mettez à jour le DOM pour afficher le message.
  },

  // Méthode personnalisée pour envoyer un message au serveur.
  speak(message) {
    this.perform("speak", { message: message });
  }
});

export default communicationChannel;
