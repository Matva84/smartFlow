document.addEventListener("DOMContentLoaded", function() {
  //console.log("🚀 DOM chargé, initialisation du graphique...");

  var expensesDataElement = document.getElementById("expensesChartData");

  if (!expensesDataElement) {
    console.error("❌ ERREUR : L'élément #expensesChartData est introuvable !");
    return;
  }

  var rawData = expensesDataElement.getAttribute("data-expenses");

  //console.log("📜 Données brutes récupérées (avant JSON.parse) :", rawData);

  if (!rawData || rawData.trim() === "") {
    console.error("❌ ERREUR : Aucune donnée trouvée !");
    return;
  }

  let expensesByEmployee;

  try {
    // Normaliser la chaîne JSON au cas où elle contiendrait des caractères spéciaux
    rawData = rawData.replace(/&quot;/g, '"');

    expensesByEmployee = JSON.parse(rawData);
    //console.log("📊 Données JSON après parsing :", expensesByEmployee);
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

  function updateChart(expensesData, labels) {
    // Si vous aviez un ancien graphique, on le détruit
    if (expensesChart !== null) {
      expensesChart.destroy();
    }

    // Construire plusieurs datasets, un par employé
    const colors = [
      "rgba(255, 99, 132, 0.6)",
      "rgba(54, 162, 235, 0.6)",
      "rgba(255, 206, 86, 0.6)",
      "rgba(75, 192, 192, 0.6)",
      "rgba(153, 102, 255, 0.6)",
      "rgba(255, 159, 64, 0.6)"
    ];
    let colorIndex = 0;
    let datasets = [];

    // expensesData est du type :
    // {
    //   "Fabien BRIEQUE": [289.0, 25.0],
    //   "Romain BAILLIER": [9.0, 0],
    //   ...
    // }

    Object.keys(expensesData).forEach((employee) => {
      datasets.push({
        label: employee,
        data: expensesData[employee],
        backgroundColor: colors[colorIndex % colors.length],
        borderColor: colors[colorIndex % colors.length].replace("0.6", "1"),
        borderWidth: 2,
        fill: false,
        tension: 0.4
      });
      colorIndex++;
    });

    expensesChart = new Chart(ctx, {
      type: "line", // ou "bar" selon votre besoin
      data: {
        labels: labels,  // ["Jan 2025", "Fév 2025", ...]
        datasets: datasets
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: {
            beginAtZero: false
          }
        },
        plugins: {
          legend: {
            display: true
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
  }

  function generateChart(data) {
    if (expensesChart) {
      //console.log("🗑️ Suppression de l'ancien graphique...");
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

    //console.log("✅ Graphique mis à jour !");
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

    //console.log(`🔄 Mise à jour du graphique avec les dépenses depuis ${selectedDate}...`);

    fetch(`/expenses/global_expenses_by_date?start_date=${selectedDate}`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`Erreur HTTP : ${response.status} - ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        //console.log("✅ Données mises à jour :", data);
        updateChart(data);
      })
      .catch(error => console.error("❌ ERREUR : Impossible de récupérer les nouvelles données :", error));
  });

  function updateTable(tableData) {
    var table = document.getElementById("expensesCategoryTable");
    var thead = table.querySelector("thead tr");
    var tbody = table.querySelector("tbody");

    // Réinitialiser l'en-tête et le corps du tableau
    thead.innerHTML = "<th>Employé</th>";
    tbody.innerHTML = "";

    // Ajouter les colonnes pour chaque catégorie
    tableData.categories.forEach(function(cat) {
      var th = document.createElement("th");
      th.innerText = cat;
      thead.appendChild(th);
    });

    // Pour chaque employé, ajouter une ligne avec la somme par catégorie
    Object.keys(tableData.data).forEach(function(employee) {
      var row = document.createElement("tr");

      var tdName = document.createElement("td");
      tdName.innerText = employee;
      row.appendChild(tdName);

      tableData.categories.forEach(function(cat) {
        var td = document.createElement("td");
        // Affiche 0 si aucune dépense dans la catégorie
        td.innerText = tableData.data[employee][cat] || 0;
        row.appendChild(td);
      });

      tbody.appendChild(row);
    });
  }

  // Dans la fonction qui met à jour le graphique (après le fetch)
  document.getElementById("updateChart").addEventListener("click", function() {
    let startDate = document.getElementById("start_date").value;
    let endDate = document.getElementById("end_date").value;
    if (!startDate || !endDate) {
      alert("Veuillez sélectionner une date de début et une date de fin !");
      return;
    }

    fetch(`/expenses/global_expenses_by_date?start_date=${startDate}&end_date=${endDate}`)
      .then(response => {
        if (!response.ok) {
          throw new Error(`Erreur HTTP : ${response.status} - ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        updateChart(data);
        // Mettre à jour le tableau avec les données par catégorie
        updateTable(data.table);
      })
      .catch(error => console.error("❌ ERREUR : Impossible de récupérer les nouvelles données :", error));
  });
  // Gestionnaire pour "Année en cours"
  document.getElementById("currentYear").addEventListener("click", function() {
    console.log("Bouton 'Année en cours' cliqué.");
    const currentYear = new Date().getFullYear();
    document.getElementById("start_date").value = `${currentYear}-01-01`;
    document.getElementById("end_date").value = new Date().toISOString().slice(0, 10);

    // Récupérer les valeurs mises à jour depuis le DOM
    const startDate = document.getElementById("start_date").value;
    const endDate = document.getElementById("end_date").value;
    console.log("Bouton 'Année en cours' - start_date:", startDate, "end_date:", endDate);

    var url = `/expenses/global_expenses_by_date?start_date=${startDate}&end_date=${endDate}`;
    console.log("Bouton 'Année en cours' - Fetch URL:", url);

    fetch(url)
      .then(response => {
        console.log("Bouton 'Année en cours' - Réponse HTTP:", response.status);
        if (!response.ok) {
          throw new Error(`Erreur HTTP : ${response.status} - ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        // Vérifier la présence de data.data et data.labels
        if (!data.data || !data.labels) {
          console.error("❌ ERREUR : data.data ou data.labels manquant(s) !");
          return;
        }

        // On transmet la partie "data" et la partie "labels"
        updateChart(data.data, data.labels);

        // Pour le tableau
        if (data.table) {
          updateTable(data.table);
        }
      })


      .catch(error => console.error("❌ ERREUR : Impossible de récupérer les nouvelles données (Année en cours):", error));
  });

  // Gestionnaire pour "Mois en cours"
  document.getElementById("currentMonth").addEventListener("click", function() {
    console.log("Bouton 'Mois en cours' cliqué.");
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1; // Les mois commencent à 0 en JavaScript
    const formattedMonth = month < 10 ? `0${month}` : month;
    document.getElementById("start_date").value = `${year}-${formattedMonth}-01`;
    document.getElementById("end_date").value = new Date().toISOString().slice(0, 10);

    const startDate = document.getElementById("start_date").value;
    const endDate = document.getElementById("end_date").value;
    console.log("Bouton 'Mois en cours' - start_date:", startDate, "end_date:", endDate);

    var url = `/expenses/global_expenses_by_date?start_date=${startDate}&end_date=${endDate}`;
    console.log("Bouton 'Mois en cours' - Fetch URL:", url);

    fetch(url)
      .then(response => {
        console.log("Bouton 'Mois en cours' - Réponse HTTP:", response.status);
        if (!response.ok) {
          throw new Error(`Erreur HTTP : ${response.status} - ${response.statusText}`);
        }
        return response.json();
      })
      .then(data => {
        // Vérifier la présence de data.data et data.labels
        if (!data.data || !data.labels) {
          console.error("❌ ERREUR : data.data ou data.labels manquant(s) !");
          return;
        }

        // On transmet la partie "data" et la partie "labels"
        updateChart(data.data, data.labels);

        // Pour le tableau
        if (data.table) {
          updateTable(data.table);
        }
      })


      .catch(error => console.error("❌ ERREUR : Impossible de récupérer les nouvelles données (Mois en cours):", error));
  });
});
