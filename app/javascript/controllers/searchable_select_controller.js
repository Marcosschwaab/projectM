import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]
  static values = {
    placeholder: { type: String, default: "Search..." }
  }

  connect() {
    this.selectTarget.style.display = "none"

    this.wrapper = document.createElement("div")
    this.wrapper.className = "relative"

    const selectClasses = Array.from(this.selectTarget.classList)
    this.input = document.createElement("input")
    this.input.type = "text"
    this.input.className = selectClasses.join(" ")
    this.input.placeholder = this.placeholderValue
    this.input.autocomplete = "off"

    this.dropdown = document.createElement("div")
    this.dropdown.className = "hidden absolute z-10 w-full mt-1 bg-white dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg shadow-lg max-h-48 overflow-y-auto"

    this.selectTarget.parentNode.insertBefore(this.wrapper, this.selectTarget)
    this.wrapper.appendChild(this.input)
    this.wrapper.appendChild(this.dropdown)

    this.populateDropdown()
    this.syncInputFromSelect()

    this.input.addEventListener("input", () => {
      this.filter()
      this.dropdown.classList.remove("hidden")
    })

    this.input.addEventListener("focus", () => {
      this.filter()
      this.dropdown.classList.remove("hidden")
    })

    this.input.addEventListener("blur", () => {
      setTimeout(() => this.dropdown.classList.add("hidden"), 200)
    })

    this.input.addEventListener("keydown", (e) => {
      if (e.key === "Escape") this.dropdown.classList.add("hidden")
    })

    this.dropdown.addEventListener("mousedown", (e) => {
      const item = e.target.closest("[data-value]")
      if (item) this.selectOption(item.dataset.value, item.textContent)
    })
  }

  populateDropdown() {
    this.allOptions = Array.from(this.selectTarget.options).map(o => ({
      value: o.value,
      text: o.text,
      selected: o.selected,
      disabled: o.disabled
    }))
    this.renderDropdown()
  }

  renderDropdown(filter) {
    const q = (filter || "").toLowerCase()
    const filtered = this.allOptions.filter(o =>
      o.value === "" || o.text.toLowerCase().includes(q)
    )

    this.dropdown.innerHTML = filtered.map(o => {
      const classes = [
        "px-3 py-2 cursor-pointer text-sm",
        o.selected ? "bg-indigo-50 dark:bg-gray-600 font-medium text-indigo-700 dark:text-indigo-300" : "text-gray-700 dark:text-gray-200",
        o.disabled ? "opacity-50 cursor-not-allowed" : "hover:bg-indigo-50 dark:hover:bg-gray-600"
      ].join(" ")
      return `<div class="${classes}" data-value="${o.value}">${this.escapeHtml(o.text)}</div>`
    }).join("")
  }

  filter() {
    this.renderDropdown(this.input.value)
  }

  selectOption(value, text) {
    this.selectTarget.value = value
    this.selectTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.syncInputFromSelect()
    this.dropdown.classList.add("hidden")
  }

  syncInputFromSelect() {
    const selected = this.selectTarget.options[this.selectTarget.selectedIndex]
    if (selected && selected.value !== "") {
      this.input.value = selected.text
    } else {
      this.input.value = ""
    }
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
