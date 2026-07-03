import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "icon"]

  connect() {
    this.open = true
  }

  toggle() {
    this.open = !this.open
    this.bodyTarget.classList.toggle("hidden", !this.open)
    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle("-rotate-180", !this.open)
    }
  }
}
