document.addEventListener("DOMContentLoaded", function() {
  //console.log("🚀 DOM chargé, initialisation du graphique...");

  var canvas = document.getElementById("expensesChart");

  if (!canvas) {
    console.error("❌ ERREUR : L'élément #expensesChart n'existe pas dans le DOM !");
    return;
  }

  var ctx = canvas.getContext("2d");
  var expensesChart = null; // Stocke le graphique pour le détruire plus tard

  var expensesDataElement = document.getElementById("expensesChartData");

  if (!expensesDataElement) {
    console.error("❌ ERREUR : L'élément #expensesChartData est introuvable !");
    return;
  }

  var employeeId = expensesDataElement.getAttribute("data-employee-id");

  if (!employeeId) {
    console.error("❌ ERREUR : Aucun ID d'employé trouvé !");
    return;
  }

  var currentYear = new Date().getFullYear();

  function fetchExpensesData(year) {
    //console.log(`🔄 Récupération des données pour l'année : ${year}`);

    fetch(`/employees/${employeeId}/expenses_by_year?year=${year}`)
      .then(response => {
        if (!response.ok) {
          throw new Error("Erreur réseau");
        }
        return response.json();
      })
      .then(data => {
        //console.log("✅ Données reçues :", data);

        if (!data.expenses) {
          console.error("❌ ERREUR : Données manquantes !");
          return;
        }

        updateChart(data.expenses, data.year);
      })
      .catch(error => {
        console.error("❌ ERREUR : Impossible de récupérer les données :", error);
      });
  }

  function updateChart(newData, year) {
    if (expensesChart !== null) {
      //console.log("🗑️ Suppression de l'ancien graphique...");
      expensesChart.destroy(); // 🔥 Supprime le graphique avant d'en créer un nouveau
    }

    //console.log("📊 Création du nouveau graphique...");
    expensesChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"],
        datasets: [{
          data: newData,
          backgroundColor: "rgba(255, 99, 132, 0.5)",
          borderColor: "rgba(255, 99, 132, 1)",
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false, // ✅ Empêche la déformation
        scales: {
          y: {
            beginAtZero: true
          }
        },
        plugins: {
          legend: {
            display: false  // La légende est masquée
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return context.raw + " €";
              }
            }
          }
        }
      }
    });

    // Met à jour l'année affichée
    document.getElementById("selectedYear").innerText = year;
  }

  // Chargement initial avec l'année actuelle
  fetchExpensesData(currentYear);

  // Ajouter les événements aux boutons de navigation
  document.getElementById("prevYear").addEventListener("click", function(event) {
    event.preventDefault();
    currentYear -= 1;
    fetchExpensesData(currentYear);
  });

  document.getElementById("nextYear").addEventListener("click", function(event) {
    event.preventDefault();
    currentYear += 1;
    fetchExpensesData(currentYear);
  });
});
