document.addEventListener("DOMContentLoaded", function() {
  console.log("🚀 DOM chargé, initialisation du graphique et des filtres...");

  var canvas = document.getElementById("expensesChart");
  if (!canvas) {
    console.error("❌ ERREUR : L'élément #expensesChart n'existe pas dans le DOM !");
    return;
  }
  var ctx = canvas.getContext("2d");
  var expensesChart = null; // Stocke le graphique pour le détruire plus tard

  // Fonction pour récupérer et afficher les données globales
  function fetchGlobalExpensesData() {
    // Récupérer les dates de début et de fin depuis les inputs
    var startDate = document.getElementById("start_date").value;
    var endDate = document.getElementById("end_date").value;
    console.log("fetchGlobalExpensesData - start_date:", startDate, "end_date:", endDate);

    if (!startDate || !endDate) {
      console.error("❌ ERREUR : Les dates de début et/ou de fin ne sont pas renseignées !");
      return;
    }

    var url = `/expenses/global_expenses_by_date?start_date=${startDate}&end_date=${endDate}`;
    console.log("fetchGlobalExpensesData - URL:", url);

    fetch(url)
      .then(response => {
        console.log("fetchGlobalExpensesData - Réponse HTTP:", response.status);
        if (!response.ok) {
          throw new Error("Erreur réseau");
        }
        return response.json();
      })
      .then(data => {
        console.log("fetchGlobalExpensesData - Données reçues:", data);
        if (!data.data) {
          console.error("❌ ERREUR : Données manquantes !");
          return;
        }
        // Mettre à jour le graphique
        updateChart(data.data, data.labels);
        // Mettre à jour le tableau si la donnée est présente
        if (data.table) {
          updateTable(data.table);
        } else {
          console.warn("fetchGlobalExpensesData - Pas de données de table reçues.");
        }
      })
      .catch(error => {
        console.error("❌ ERREUR : Impossible de récupérer les données :", error);
      });
  }

  function updateChart(expensesData, labels) {
    console.log("updateChart - Mise à jour du graphique avec données:", expensesData, "et labels:", labels);
    if (expensesChart !== null) {
      console.log("updateChart - Destruction de l'ancien graphique.");
      expensesChart.destroy();
    }

    expensesChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels, // par exemple ["Jan", "Fév", ...]
        datasets: [{
          data: expensesData,
          backgroundColor: "rgba(255, 99, 132, 0.5)",
          borderColor: "rgba(255, 99, 132, 1)",
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: true
          }
        },
        plugins: {
          legend: {
            display: false
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
    console.log("updateChart - Nouveau graphique créé.");
  }

  function updateTable(tableData) {
    console.log("updateTable - Mise à jour du tableau avec données:", tableData);
    var table = document.getElementById("expensesCategoryTable");
    if (!table) {
      console.error("❌ ERREUR : L'élément #expensesCategoryTable est introuvable !");
      return;
    }
    var thead = table.querySelector("thead tr");
    var tbody = table.querySelector("tbody");

    // Réinitialiser l'en-tête et le corps du tableau
    thead.innerHTML = "";
    tbody.innerHTML = "";

    // Construire la première ligne de l'en-tête : Employé + Total
    var thEmployee = document.createElement("th");
    thEmployee.innerText = "Employé";
    thead.appendChild(thEmployee);

    var thTotal = document.createElement("th");
    thTotal.innerText = "Total";
    thead.appendChild(thTotal);

    // Ajouter les colonnes pour chaque catégorie
    tableData.categories.forEach(function(cat) {
      var th = document.createElement("th");
      th.innerText = cat;
      thead.appendChild(th);
    });

    // Pour chaque employé, ajouter une ligne avec la somme par catégorie
    Object.keys(tableData.data).forEach(function(employee) {
      var row = document.createElement("tr");

      // Nom de l'employé
      var tdName = document.createElement("td");
      tdName.innerText = employee;
      row.appendChild(tdName);

      // Calcul du total pour cet employé
      var total = 0;
      tableData.categories.forEach(function(cat) {
        total += tableData.data[employee][cat] || 0;
      });

      // Colonne Total
      var tdTotal = document.createElement("td");
      tdTotal.innerText = total;
      row.appendChild(tdTotal);

      // Colonnes par catégorie
      tableData.categories.forEach(function(cat) {
        var td = document.createElement("td");
        // Affiche 0 si aucune dépense dans la catégorie
        td.innerText = tableData.data[employee][cat] || 0;
        row.appendChild(td);
      });

      tbody.appendChild(row);
    });
    console.log("updateTable - Tableau mis à jour.");
  }


  // Chargement initial dès que la page est prête
  console.log("Chargement initial des données globales...");
  fetchGlobalExpensesData();

  // Ajout de l'événement sur le bouton "Mettre à jour"
  document.getElementById("updateChart").addEventListener("click", function() {
    console.log("Bouton 'Mettre à jour' cliqué.");
    fetchGlobalExpensesData();
  });

});
