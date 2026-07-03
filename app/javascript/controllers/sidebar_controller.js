import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop"]

  toggle() {
    if (this.sidebarTarget.classList.contains("-translate-x-full")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.sidebarTarget.classList.remove("-translate-x-full")
    this.sidebarTarget.classList.add("translate-x-0")
    this.backdropTarget.classList.remove("hidden", "opacity-0")
    this.backdropTarget.classList.add("opacity-100")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.sidebarTarget.classList.add("-translate-x-full")
    this.sidebarTarget.classList.remove("translate-x-0")
    this.backdropTarget.classList.add("opacity-0")
    this.backdropTarget.classList.remove("opacity-100")
    setTimeout(() => {
      this.backdropTarget.classList.add("hidden")
      if (window.innerWidth < 1024) {
        document.body.style.overflow = ""
      }
    }, 300)
  }
}
