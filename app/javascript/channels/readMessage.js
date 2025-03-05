document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".btn-mark-read").forEach(button => {
    button.addEventListener("click", () => {
      const messageId = button.dataset.messageId;
      markMessageAsRead(messageId);
    });
  });

  function markMessageAsRead(messageId) {
    console.log(`[DEBUG] markMessageAsRead => message ${messageId}`);
    fetch(`/messages/${messageId}/mark_as_read`, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Content-Type": "application/json"
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === "ok") {
        console.log(`[DEBUG] message ${messageId} marqué comme lu côté serveur => ${data.read_at}`);
        // On attend la diffusion de broadcast_read_status pour maj l'UI
      } else {
        console.error(`[DEBUG] Erreur mark_as_read => ${JSON.stringify(data)}`);
      }
    })
    .catch(error => console.error(`[DEBUG] Exception mark_as_read => ${error}`));
  }

});
