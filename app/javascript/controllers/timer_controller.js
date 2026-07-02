import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startButton", "stopButton"]
  static values = {
    running: Boolean,
    startedAt: String
  }

  connect() {
    if (this.runningValue) {
      this.startTimer()
    }
  }

  startTimer() {
    this.runningValue = true
    this.startedAtValue = new Date().toISOString()
    this.startButtonTarget.classList.add("hidden")
    this.stopButtonTarget.classList.remove("hidden")
    this.tick()
  }

  stopTimer() {
    this.runningValue = false
    this.startButtonTarget.classList.remove("hidden")
    this.stopButtonTarget.classList.add("hidden")
    this.displayTarget.textContent = "00:00:00"
  }

  tick() {
    if (!this.runningValue) return

    const start = new Date(this.startedAtValue)
    const elapsed = Math.floor((new Date() - start) / 1000)
    const h = String(Math.floor(elapsed / 3600)).padStart(2, "0")
    const m = String(Math.floor((elapsed % 3600) / 60)).padStart(2, "0")
    const s = String(elapsed % 60).padStart(2, "0")
    this.displayTarget.textContent = `${h}:${m}:${s}`

    setTimeout(() => this.tick(), 1000)
  }
}
