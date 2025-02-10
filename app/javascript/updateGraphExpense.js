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

  let selectedYearElement = document.getElementById("selectedYear");
  let chartTitleElement = document.getElementById("chartTitle");

  var employeeId = expensesDataElement.getAttribute("data-employee-id");

  if (!employeeId) {
    console.error("❌ ERREUR : Aucun ID d'employé trouvé !");
    return;
  }

  var currentYear = new Date().getFullYear();
  var selectedYear = parseInt(selectedYearElement.textContent, 10) || currentYear;

  function updateYearDisplay(year, annualTotal) {
    // On arrondit annualTotal à 2 décimales
    const totalArrondi = Number(annualTotal).toFixed(2);
    //console.log(`🆕 Mise à jour de l'affichage de l'année : ${year} avec total ${totalArrondi}`);
    if (selectedYearElement) {
      // Met à jour le contenu du span avec l'année suivie du total arrondi
      selectedYearElement.innerHTML = year + " (Total : " + totalArrondi + " €)";
    }
    if (chartTitleElement) {
      // Met à jour le titre du graphique (si vous avez un autre élément dédié à cet affichage)
      chartTitleElement.textContent = `Dépenses approuvées (€) en ${year}`;
    }
  }


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

        updateYearDisplay(year); // ✅ Mise à jour de l'année affichée
        updateChart(data.expenses, year);
      })
      .catch(error => {
        console.error("❌ ERREUR : Impossible de récupérer les données :", error);
      });
  }

  function updateChart(newData, year) {
    // Calcul de la somme annuelle des dépenses
    const annualTotal = newData.reduce((acc, value) => acc + parseFloat(value), 0);
    //console.log(annualTotal);
    // Vérifier et détruire tout graphique existant sur le canvas
    const existingChart = Chart.getChart("expensesChart");
    if (existingChart) {
      //console.log("🗑️ Destruction du graphique existant...");
      existingChart.destroy();
    }

    //console.log("📊 Création du nouveau graphique...");
    expensesChart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ["Jan", "Fév", "Mar", "Avr", "Mai", "Juin", "Juil", "Août", "Sept", "Oct", "Nov", "Déc"],
        datasets: [{
          label: `Dépenses approuvées (€) en ${year}`,
          data: newData,
          backgroundColor: "rgba(255, 99, 132, 0.5)",
          borderColor: "rgba(255, 99, 132, 1)",
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: { beginAtZero: true }
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
      },
    });

    // Mise à jour de l'affichage dans le titre de la vue
    updateYearDisplay(year, annualTotal);
  }


  // Chargement initial avec l'année sélectionnée
  fetchExpensesData(selectedYear);

  // Ajouter les événements aux boutons de navigation
  document.getElementById("prevYear").addEventListener("click", function(event) {
    event.preventDefault();
    selectedYear -= 1;
    fetchExpensesData(selectedYear);
  });

  document.getElementById("nextYear").addEventListener("click", function(event) {
    event.preventDefault();
    selectedYear += 1;
    fetchExpensesData(selectedYear);
  });

  document.getElementById("currentYearBtn").addEventListener("click", function (event) {
    event.preventDefault(); // Empêche la soumission du formulaire
    selectedYear = currentYear;
    fetchExpensesData(currentYear);
  });

});
