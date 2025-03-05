// app/javascript/controllers/item_form_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "categoryField",
    "descriptionField",
    "durationField",
    "nbPeopleField",
    "materialField",
    "unitPriceField",
    // etc.
  ]

  // Quand on change la catégorie
  onCategoryChange(event) {
    const category = this.categoryFieldTarget.value.trim()
    if (category === "") return

    // Récupère les descriptions correspondantes
    fetch(`/items/descriptions?category=${encodeURIComponent(category)}`)
      .then(response => response.json())
      .then(data => {
        // data est un tableau de descriptions
        // Ici vous pouvez soit :
        // - peupler un <datalist> pour la description
        // - ou gérer un <select> dynamiquement
        // - ou juste stocker dans un tableau interne
        // Par simplicité, on suppose un <datalist> :
        this.fillDescriptionDatalist(data)
      })
  }

  // Quand on change la description
  onDescriptionChange(event) {
    const category = this.categoryFieldTarget.value.trim()
    const description = this.descriptionFieldTarget.value.trim()
    if (category === "" || description === "") return

    fetch(`/items/last_item_info?category=${encodeURIComponent(category)}&description=${encodeURIComponent(description)}`)
      .then(response => response.json())
      .then(data => {
        // Remplir les champs s’ils existent
        if (data.duration !== undefined) {
          this.durationFieldTarget.value = data.duration
        }
        if (data.nb_people !== undefined) {
          this.nbPeopleFieldTarget.value = data.nb_people
        }
        if (data.material !== undefined) {
          this.materialFieldTarget.value = data.material
        }
        if (data.unit_price_ht !== undefined) {
          this.unitPriceFieldTarget.value = data.unit_price_ht
        }
        // etc.
      })
  }

  fillDescriptionDatalist(descriptions) {
    // Exemple si vous avez un <datalist id="descriptionList">
    // et un <input list="descriptionList" ... >
    // ou si vous préférez un <select>
    const dataList = document.getElementById("descriptionList")
    if (!dataList) return

    // Vider la liste avant
    dataList.innerHTML = ""
    descriptions.forEach(desc => {
      const option = document.createElement("option")
      option.value = desc
      dataList.appendChild(option)
    })
  }
}
