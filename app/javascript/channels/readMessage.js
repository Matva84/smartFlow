document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".btn-mark-read").forEach(button => {
    button.addEventListener("click", () => {
      const messageId = button.dataset.messageId;
      markMessageAsRead(messageId);
    });
  });

  function markMessageAsRead(messageId) {
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
        console.log(`Message ${messageId} marqué comme lu : ${data.read_at}`);
        // Vous pouvez mettre à jour l’UI (retirer le bouton, etc.)
        const btn = document.querySelector(`.btn-mark-read[data-message-id="${messageId}"]`);
        if (btn) {
          btn.remove();
        }
      } else {
        console.error("Erreur mark_as_read:", data);
      }
    })
    .catch(error => console.error("Erreur fetch:", error));
  }
});
