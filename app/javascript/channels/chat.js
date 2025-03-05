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

  // Souscription pour recevoir les messages en temps réel
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

        // 1) S’il s’agit d’un NOUVEAU message (data.message présent)
        if (data.message) {
          const messagesContainer = document.getElementById("messages");

          // Créer le conteneur principal
          const container = document.createElement("div");
          container.classList.add("message-container");
          container.classList.add(data.user === currentUserEmail ? "self" : "other");
          // Stoker l'ID du message pour une future mise à jour
          container.setAttribute("data-message-id", data.message_id);

          // La bulle
          const bubble = document.createElement("div");
          bubble.classList.add("message-bubble");
          bubble.textContent = data.message;

          // Gérer les documents (inchangé)
          if (data.document_urls && data.document_urls.length > 0) {
            console.log("document_urls reçu :", data.document_urls);
            const docsContainer = document.createElement("div");
            docsContainer.classList.add("message-documents");

            data.document_urls.forEach(obj => {
              const thumbContainer = document.createElement("div");
              thumbContainer.classList.add("document-thumbnail");
              thumbContainer.style.display = "inline-block";
              thumbContainer.style.margin = "5px";

              const link = document.createElement("a");
              link.href = obj.original_url;
              link.target = "_blank";

              const img = document.createElement("img");
              if (obj.is_image && obj.thumbnail_url) {
                img.src = obj.thumbnail_url;
                img.alt = "Aperçu de l'image";
              } else {
                img.src = "/assets/generic_document_icon.png";
                img.alt = "Document";
                img.width = 100;
                img.height = 100;
              }
              img.style.maxWidth = "100px";
              img.style.maxHeight = "100px";

              link.appendChild(img);
              thumbContainer.appendChild(link);
              docsContainer.appendChild(thumbContainer);
            });

            bubble.appendChild(docsContainer);
          }

          // Le timestamp
          const timestamp = document.createElement("div");
          timestamp.classList.add("message-timestamp");

          // Déterminer si l'émetteur doit voir "(Non lu)" ou "(Lu)"
          let readStatus = "";
          if (data.user === currentUserEmail) {
            // Si c’est MON message
            if (data.read_at === null) {
              readStatus = " (Non lu)";
            } else {
              readStatus = " (Lu)";
            }
          }

          // Auto-lu si le destinataire est déjà sur la page show
          if (
            data.recipient_id === currentUserEmail &&
            data.read_at === null &&
            data.messageable_id == messageableId
          ) {
            console.log("[DEBUG] Le destinataire est déjà sur la page => on marque comme lu");
            markMessageAsRead(data.message_id);
          }

          timestamp.textContent = `${data.full_name} - ${data.sent_at}${readStatus}`;

          container.appendChild(bubble);
          container.appendChild(timestamp);
          messagesContainer.appendChild(container);
          messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }

        // 2) SI on reçoit un payload de lecture (read_at != null) SANS data.message
        //    => On met à jour "(Non lu)" => "(Lu)" dans le DOM
        if (data.message_id && data.read_at && !data.message) {
          console.log("[DEBUG] Notification read_status => message", data.message_id, "read_at=", data.read_at);
          const msgContainer = document.querySelector(`.message-container[data-message-id="${data.message_id}"]`);
          if (msgContainer) {
            const timestampElem = msgContainer.querySelector(".message-timestamp");
            if (timestampElem) {
              timestampElem.textContent = timestampElem.textContent.replace(" (Non lu)", " (Lu)");
            }
          }
        }
      }

    }
  );

  const contentInput = document.getElementById("message_content");
  const fileInput = document.getElementById("message_documents");

  // Écouteur pour envoyer le texte lorsqu'on appuie sur Entrée
  contentInput.addEventListener("keydown", event => {
    if (event.key === "Enter") {
      event.preventDefault();
      sendMessage(); // fonction qui envoie le message
    }
  });

  // Écouteur pour envoyer les fichiers lorsqu'on sélectionne un ou plusieurs documents
  fileInput.addEventListener("change", () => {
    if (fileInput.files.length > 0) {
      sendMessage();
    }
  });

  function sendMessage() {
    const message = contentInput.value.trim();
    // Si ni texte ni fichier, on n’envoie pas
    if (message === "" && fileInput.files.length === 0) return;

    const formData = new FormData();
    formData.append("message[content]", message);
    formData.append("messageable_type", messageableType);
    formData.append("messageable_id", messageableId);

    for (let i = 0; i < fileInput.files.length; i++) {
      formData.append("message[documents][]", fileInput.files[i]);
    }

    // Récupérer le token CSRF
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');

    fetch("/messages", {
      method: "POST",
      body: formData,
      credentials: "same-origin",
      headers: {
        "X-CSRF-Token": token
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === "ok") {
        // Réinitialiser le champ texte et le champ file
        contentInput.value = "";
        fileInput.value = "";
      } else {
        console.error("Erreur lors de l'envoi du message:", data.errors);
      }
    })
    .catch(error => console.error("Erreur fetch:", error));
  }
});
