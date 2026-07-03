import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "backdrop", "panel", "body", "title"]

  connect() {
    this.boundHandleResponse = this.handleResponse.bind(this)
  }

  open(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.url || event.currentTarget.href
    const title = event.currentTarget.dataset.modalTitle || "Task"

    if (this.titleTarget) this.titleTarget.textContent = title
    this.containerTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")
      this.panelTarget.classList.remove("translate-x-full")
      this.panelTarget.classList.add("translate-x-0")
    })

    document.body.style.overflow = "hidden"

    if (url) {
      this.bodyTarget.innerHTML = `
        <div class="flex items-center justify-center py-12">
          <div class="w-6 h-6 border-2 border-indigo-600 border-t-transparent rounded-full animate-spin"></div>
        </div>`
      fetch(url, {
        headers: { "Accept": "text/html" },
        credentials: "same-origin"
      })
      .then(response => response.text())
      .then(this.boundHandleResponse)
      .catch(() => {
        this.bodyTarget.innerHTML = `<p class="text-sm text-red-500 text-center py-8">Failed to load task.</p>`
      })
    }
  }

  handleResponse(html) {
    this.bodyTarget.innerHTML = html
  }

  close(event) {
    if (event && event.type === "click" && event.currentTarget !== this.backdropTarget && event.currentTarget !== this.element?.querySelector("[data-action~='slideover#close']")) {
      const isButton = event.currentTarget?.matches("button") || event.target?.closest("button")
      if (!isButton && event.currentTarget !== this.backdropTarget) return
    }

    this.panelTarget.classList.remove("translate-x-0")
    this.panelTarget.classList.add("translate-x-full")
    this.backdropTarget.classList.remove("opacity-100")
    this.backdropTarget.classList.add("opacity-0")

    setTimeout(() => {
      this.containerTarget.classList.add("hidden")
      document.body.style.overflow = ""
    }, 300)
  }
}
