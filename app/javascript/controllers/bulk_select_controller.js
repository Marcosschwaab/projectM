import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "selectAll", "bar", "count", "selectedIds"]

  connect() {
    this.ids = new Set()
  }

  toggle(event) {
    const checkbox = event.currentTarget
    if (checkbox.checked) {
      this.ids.add(checkbox.value)
    } else {
      this.ids.delete(checkbox.value)
      if (this.hasSelectAllTarget) this.selectAllTarget.checked = false
    }
    this.update()
  }

  toggleAll(event) {
    const checked = event.currentTarget.checked
    this.checkboxTargets.forEach(cb => {
      cb.checked = checked
      if (checked) {
        this.ids.add(cb.value)
      } else {
        this.ids.delete(cb.value)
      }
    })
    this.update()
  }

  clear() {
    this.ids.clear()
    this.checkboxTargets.forEach(cb => cb.checked = false)
    if (this.hasSelectAllTarget) this.selectAllTarget.checked = false
    this.update()
  }

  update() {
    if (this.hasCountTarget) {
      this.countTarget.textContent = this.ids.size
    }
    if (this.hasBarTarget) {
      this.barTarget.classList.toggle("hidden", this.ids.size === 0)
    }
    if (this.hasSelectedIdsTarget) {
      this.selectedIdsTarget.value = Array.from(this.ids).join(",")
    }
  }

  confirmDelete(event) {
    if (this.ids.size === 0) {
      event.preventDefault()
      return
    }
    const template = this.element.dataset.confirmMessage
    const message = template.replace("{{count}}", this.ids.size)
    if (!confirm(message)) {
      event.preventDefault()
    }
  }
}
