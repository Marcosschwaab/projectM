import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["endDate"]

  connect() {
    const select = this.element.querySelector("select[name*='[recurrence_rule]']")
    if (select) {
      select.addEventListener("change", () => this.toggle(select))
      this.toggle(select)
    }
  }

  toggle(select) {
    const show = select.value !== ""
    this.endDateTarget.classList.toggle("hidden", !show)
  }
}
