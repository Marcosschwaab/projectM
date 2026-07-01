import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  markRead(event) {
    const url = this.element.dataset.notificationReadUrl
    if (!url) return

    fetch(url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
        "Accept": "text/html"
      }
    })

    const badge = document.querySelector("[data-notification-count]")
    if (badge) {
      const count = parseInt(badge.textContent) - 1
      badge.textContent = count
      if (count <= 0) {
        badge.classList.add("hidden")
      }
    }

    this.element.classList.remove("bg-indigo-50/30", "cursor-pointer")
    this.element.classList.add("hover:bg-gray-50")
  }
}
