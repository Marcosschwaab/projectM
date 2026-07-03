import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.currentIndex = 0
  }

  switch(event) {
    event.preventDefault()
    const index = parseInt(event.currentTarget.dataset.index)
    if (index === this.currentIndex) return

    const activeClasses = [
      "border-indigo-600", "text-indigo-600",
      "dark:border-indigo-400", "dark:text-indigo-400"
    ]
    const inactiveClasses = [
      "border-transparent", "text-gray-500", "hover:text-gray-700",
      "dark:text-gray-400", "dark:hover:text-gray-300"
    ]

    this.tabTargets.forEach((tab, i) => {
      tab.classList.remove(...activeClasses, ...inactiveClasses)
      if (i === index) {
        tab.classList.add(...activeClasses)
        tab.setAttribute("aria-selected", "true")
      } else {
        tab.classList.add(...inactiveClasses)
        tab.setAttribute("aria-selected", "false")
      }
    })

    this.panelTargets.forEach((panel, i) => {
      panel.classList.toggle("hidden", i !== index)
    })

    this.currentIndex = index
  }
}
