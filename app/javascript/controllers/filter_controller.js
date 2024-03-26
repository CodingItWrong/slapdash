import { Controller } from "@hotwired/stimulus"

export default class FilterController extends Controller {
  static targets = ["filterTextField", "listItem"]

  connect() {
    this.filterTextFieldTarget.focus()
  }

  update() {
    const filterText = this.filterTextFieldTarget.value.trim().toLowerCase()
    for (let listItem of this.listItemTargets) {
      const itemText = listItem.innerText.trim().toLowerCase()
      const shouldHide = filterText && !itemText.includes(filterText)
      listItem.classList.toggle("d-none", shouldHide)
    }
  }
}
