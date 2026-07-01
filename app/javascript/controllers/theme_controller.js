import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { theme: String }

  connect() {
    const saved = localStorage.getItem("theme")
    if (saved) {
      this.apply(saved)
    } else {
      this.apply(this.themeValue || "system")
    }
  }

  toggle(event) {
    event.preventDefault()
    const current = this.current()
    const next = current === "dark" ? "light" : "dark"
    this.apply(next)
    localStorage.setItem("theme", next)
    this.persist(next)
  }

  apply(theme) {
    const resolved = theme === "system"
      ? (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
      : theme

    document.documentElement.classList.toggle("dark", resolved === "dark")
  }

  current() {
    return localStorage.getItem("theme") || this.themeValue || "system"
  }

  persist(theme) {
    const meta = document.querySelector('meta[name="csrf-token"]')
    const token = meta ? meta.content : ""
    fetch("/theme", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "text/html"
      },
      body: JSON.stringify({ theme })
    })
  }
}
