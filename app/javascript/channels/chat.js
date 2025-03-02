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
        const messagesContainer = document.getElementById("messages");

        const container = document.createElement("div");
        container.classList.add("message-container");
        container.classList.add(data.user === currentUserEmail ? "self" : "other");

        const bubble = document.createElement("div");
        bubble.classList.add("message-bubble");
        bubble.textContent = data.message;

        if (data.document_urls && data.document_urls.length > 0) {
          console.log("document_urls reçu :", data.document_urls); // Log pour debug
          const docsContainer = document.createElement("div");
          docsContainer.classList.add("message-documents");

          data.document_urls.forEach(obj => {
            // obj est un objet { thumbnail_url, original_url, is_image }

            // Conteneur pour la vignette
            const thumbContainer = document.createElement("div");
            thumbContainer.classList.add("document-thumbnail");
            thumbContainer.style.display = "inline-block";
            thumbContainer.style.margin = "5px";

            // Lien vers le document original
            const link = document.createElement("a");
            link.href = obj.original_url;
            link.target = "_blank";

            // Élément <img>
            const img = document.createElement("img");
            if (obj.is_image && obj.thumbnail_url) {
              img.src = obj.thumbnail_url;
              img.alt = "Aperçu de l'image";
            } else {
              // Icône générique pour un PDF, Word, etc.
              img.src = "/assets/generic_document_icon.png";
              img.alt = "Document";
              img.width = 100;
              img.height = 100;
            }
            img.style.maxWidth = "100px";
            img.style.maxHeight = "100px";

            // Insérer <img> dans <a>, puis dans le container
            link.appendChild(img);
            thumbContainer.appendChild(link);
            docsContainer.appendChild(thumbContainer);
          });

          bubble.appendChild(docsContainer);
        }


        const timestamp = document.createElement("div");
        timestamp.classList.add("message-timestamp");
        timestamp.textContent = `${data.full_name} - ${data.sent_at}`;

        container.appendChild(bubble);
        container.appendChild(timestamp);
        messagesContainer.appendChild(container);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
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
