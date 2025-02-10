document.addEventListener("DOMContentLoaded", function() {
  console.log("🚀 DOM chargé, initialisation du graphique...");

  var expensesDataElement = document.getElementById("expensesChartData");

  if (!expensesDataElement) {
    console.error("❌ ERREUR : L'élément #expensesChartData est introuvable !");
    return;
  }

  var rawData = expensesDataElement.getAttribute("data-expenses");

  console.log("📜 Données brutes récupérées (avant JSON.parse) :", rawData);

  if (!rawData || rawData.trim() === "") {
    console.error("❌ ERREUR : Aucune donnée trouvée !");
    return;
  }

  let expensesByEmployee;

  try {
    // Normaliser la chaîne JSON au cas où elle contiendrait des caractères spéciaux
    rawData = rawData.replace(/&quot;/g, '"');

    expensesByEmployee = JSON.parse(rawData);
    console.log("📊 Données JSON après parsing :", expensesByEmployee);
  } catch (error) {
    console.error("❌ ERREUR : Impossible de parser les données JSON :", error, "\nDonnées brutes:", rawData);
    return;
  }

  var ctx = document.getElementById("expensesChart").getContext("2d");

  if (!ctx) {
    console.error("❌ ERREUR : Impossible d'obtenir le contexte du canvas !");
    return;
  }

  var expensesChart; // Variable pour stocker l'instance du graphique

  function updateChart(newData) {
    if (expensesChart) {
      expensesChart.destroy();
    }

    const colors = [
      "rgba(255, 99, 132, 0.6)",
      "rgba(54, 162, 235, 0.6)",
      "rgba(255, 206, 86, 0.6)",
      "rgba(75, 192, 192, 0.6)",
      "rgba(153, 102, 255, 0.6)",
      "rgba(255, 159, 64, 0.6)"
    ];

    let datasets = [];
    let colorIndex = 0;

    Object.keys(newData.data).forEach((employee) => {
      let total = newData.totals[employee];
      datasets.push({
        // On utilise "\n" pour forcer un retour à la ligne dans la légende
        label: employee + "\n: " + total + " €",
        data: newData.data[employee],
        backgroundColor: colors[colorIndex % colors.length],
        borderColor: colors[colorIndex % colors.length].replace("0.6", "1"),
        borderWidth: 2,
        fill: false,
        tension: 0.4
      });
      colorIndex++;
    });

    expensesChart = new Chart(ctx, {
      type: "line",
      data: {
        labels: newData.labels,
        datasets: datasets
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: true,
            position: "top"
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return context.dataset.label + ": " + context.raw + " €";
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: "Montant des dépenses (€)"
            }
          },
          x: {
            title: {
              display: true,
              text: "Période"
            }
          }
        }
      }
    });

    console.log("✅ Graphique mis à jour !");
  }



  function generateChart(data) {
    if (expensesChart) {
      console.log("🗑️ Suppression de l'ancien graphique...");
      expensesChart.destroy();
    }

    // Définition des couleurs pour chaque employé
    const colors = [
      "rgba(255, 99, 132, 0.6)", "rgba(54, 162, 235, 0.6)", "rgba(255, 206, 86, 0.6)",
      "rgba(75, 192, 192, 0.6)", "rgba(153, 102, 255, 0.6)", "rgba(255, 159, 64, 0.6)"
    ];

    let datasets = [];
    let colorIndex = 0;

    Object.keys(data).forEach((employee, index) => {
      datasets.push({
        label: employee, // Nom de l'employé
        data: data[employee], // Données des dépenses par mois
        backgroundColor: colors[colorIndex % colors.length],
        borderColor: colors[colorIndex % colors.length].replace("0.6", "1"), // Opacité à 1 pour bordure
        borderWidth: 2,
        fill: false,
        tension: 0.4 // Ajoute un effet de courbe
      });
      colorIndex++;
    });

    expensesChart = new Chart(ctx, {
      type: "line", // Utilisation d'un graphique en ligne
      data: {
        labels: ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"],
        datasets: datasets
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: true,
            position: "top"
          },
          tooltip: {
            callbacks: {
              label: function(context) {
                return context.dataset.label + ": " + context.raw + " €";
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: "Montant des dépenses (€)"
            }
          },
          x: {
            title: {
              display: true,
              text: "Mois"
            }
          }
        }
      }
    });

    console.log("✅ Graphique mis à jour !");
  }

  // Générer le graphique initial
  generateChart(expensesByEmployee);

  // GESTION DE LA MISE À JOUR AVEC LE SÉLECTEUR DE DATE
  document.getElementById("updateChart").addEventListener("click", function() {
    let selectedDate = document.getElementById("start_date").value;
    if (!selectedDate) {
      alert("Veuillez sélectionner une date !");
      return;
    }

    console.log(`🔄 Mise à jour du graphique avec les dépenses depuis ${selectedDate}...`);

    fetch(`/expenses/global_expenses_by_date?start_date=${selectedDate}`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`Erreur HTTP : ${response.status} - ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        console.log("✅ Données mises à jour :", data);
        updateChart(data);
      })
      .catch(error => console.error("❌ ERREUR : Impossible de récupérer les nouvelles données :", error));
  });
});
