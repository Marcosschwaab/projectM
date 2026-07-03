import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "selected", "hiddenFields"]
  static values = {
    members: Array,
    selected: { type: Array, default: [] }
  }

  connect() {
    this.selectedIds = new Set(this.selectedValue)
    this.renderSelected()
    this.renderHiddenFields()

    this.boundHandleClickOutside = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.boundHandleClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside)
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()
    if (!query) {
      this.dropdownTarget.classList.add("hidden")
      return
    }

    const results = this.membersValue.filter(m =>
      !this.selectedIds.has(m.id) &&
      m.name.toLowerCase().includes(query)
    )

    if (results.length === 0) {
      this.dropdownTarget.classList.add("hidden")
      return
    }

    this.dropdownTarget.innerHTML = results.map(m => `
      <button type="button" data-id="${m.id}" data-action="member-search#add"
              class="w-full text-left px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-700 transition-colors cursor-pointer">
        ${this.escapeHtml(m.name)}
      </button>
    `).join("")
    this.dropdownTarget.classList.remove("hidden")
  }

  showResults() {
    if (this.inputTarget.value.trim()) {
      this.filter()
    }
  }

  add(event) {
    const id = parseInt(event.currentTarget.dataset.id)
    this.selectedIds.add(id)
    this.inputTarget.value = ""
    this.dropdownTarget.classList.add("hidden")
    this.renderSelected()
    this.renderHiddenFields()
    this.inputTarget.focus()
  }

  remove(event) {
    const id = parseInt(event.currentTarget.dataset.id)
    this.selectedIds.delete(id)
    this.renderSelected()
    this.renderHiddenFields()
    this.inputTarget.focus()
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.dropdownTarget.classList.add("hidden")
      this.inputTarget.blur()
    }
    if (event.key === "Enter") {
      event.preventDefault()
      const first = this.dropdownTarget.querySelector("button")
      if (first) first.click()
    }
    if (event.key === "Backspace" && !this.inputTarget.value && this.selectedIds.size > 0) {
      const lastId = Array.from(this.selectedIds).pop()
      this.selectedIds.delete(lastId)
      this.renderSelected()
      this.renderHiddenFields()
    }
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.add("hidden")
    }
  }

  renderSelected() {
    const members = this.membersValue.filter(m => this.selectedIds.has(m.id))
    this.selectedTarget.innerHTML = members.map(m => `
      <span class="inline-flex items-center gap-1 px-2.5 py-1 bg-indigo-50 text-indigo-700 rounded-full text-sm dark:bg-indigo-900/30 dark:text-indigo-300">
        ${this.escapeHtml(m.name)}
        <button type="button" data-id="${m.id}" data-action="member-search#remove"
                class="ml-0.5 hover:text-indigo-900 dark:hover:text-indigo-100 cursor-pointer" aria-label="Remove">
          <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
        </button>
      </span>
    `).join("")
  }

  renderHiddenFields() {
    this.hiddenFieldsTarget.innerHTML = Array.from(this.selectedIds).map(id =>
      `<input type="hidden" name="project[project_member_ids][]" value="${id}" autocomplete="off">`
    ).join("")
  }

  escapeHtml(str) {
    const div = document.createElement("div")
    div.textContent = str
    return div.innerHTML
  }
}
