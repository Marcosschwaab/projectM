import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]
  static values = {
    options: Array
  }

  connect() {
    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    const results = this.optionsValue.filter(opt =>
      opt.label.toLowerCase().includes(query)
    )

    if (results.length === 0) {
      this.dropdownTarget.classList.add("hidden")
      return
    }

    this.dropdownTarget.innerHTML = results.map(opt => `
      <button type="button" data-value="${opt.value}" data-action="combobox#select"
              class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        ${this.escapeHtml(opt.label)}
      </button>
    `).join("")
    this.dropdownTarget.classList.remove("hidden")
  }

  select(event) {
    this.inputTarget.value = event.currentTarget.dataset.value
    this.dropdownTarget.classList.add("hidden")
    this.inputTarget.focus()
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.dropdownTarget.classList.add("hidden")
      this.inputTarget.blur()
    }
    if (event.key === "Enter") {
      const first = this.dropdownTarget.querySelector("button")
      if (first) {
        event.preventDefault()
        first.click()
      }
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.add("hidden")
    }
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
