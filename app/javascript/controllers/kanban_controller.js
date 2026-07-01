import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["column"]
  static values = { projectId: Number }

  connect() {
    this.dragCard = null
    this.bindEvents()
    this.subscribeToChannel()
  }

  disconnect() {
    this.unbindEvents()
    this.unsubscribe()
  }

  subscribeToChannel() {
    if (!this.hasProjectIdValue) return
    this.subscription = consumer.subscriptions.create(
      { channel: "TasksChannel", project_id: this.projectIdValue },
      {
        received: (data) => {
          if (data.action === "move") {
            const card = this.element.querySelector(`[data-task-id="${data.task_id}"]`)
            if (card) card.remove()
            const column = this.element.querySelector(`[data-status="${data.status}"] .kanban-column-body`)
            if (column) column.insertAdjacentHTML("beforeend", data.html)
          } else if (data.action === "update") {
            const card = this.element.querySelector(`[data-task-id="${data.task_id}"]`)
            if (card) card.outerHTML = data.html
          }
        }
      }
    )
  }

  unsubscribe() {
    if (this.subscription) {
      consumer.subscriptions.remove(this.subscription)
    }
  }

  bindEvents() {
    this.element.addEventListener("dragstart", this.onDragStart)
    this.element.addEventListener("dragend", this.onDragEnd)
    this.element.addEventListener("dragover", this.onDragOver)
    this.element.addEventListener("dragenter", this.onDragEnter)
    this.element.addEventListener("dragleave", this.onDragLeave)
    this.element.addEventListener("drop", this.onDrop)
  }

  unbindEvents() {
    this.element.removeEventListener("dragstart", this.onDragStart)
    this.element.removeEventListener("dragend", this.onDragEnd)
    this.element.removeEventListener("dragover", this.onDragOver)
    this.element.removeEventListener("dragenter", this.onDragEnter)
    this.element.removeEventListener("dragleave", this.onDragLeave)
    this.element.removeEventListener("drop", this.onDrop)
  }

  onDragStart = (event) => {
    const card = event.target.closest(".kanban-card")
    if (!card) return
    this.dragCard = card
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", card.dataset.taskId)
    requestAnimationFrame(() => card.classList.add("opacity-40", "scale-95"))
  }

  onDragEnd = (event) => {
    const card = event.target.closest(".kanban-card")
    if (card) card.classList.remove("opacity-40", "scale-95")
    this.columnTargets.forEach(col => col.classList.remove("bg-indigo-50/50", "ring-2", "ring-indigo-300"))
    this.dragCard = null
  }

  onDragOver = (event) => {
    const column = event.target.closest(".kanban-column-body")
    if (!column || !this.dragCard) return
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
  }

  onDragEnter = (event) => {
    const column = event.target.closest(".kanban-column-body")
    if (!column || !this.dragCard) return
    event.preventDefault()
    column.classList.add("bg-indigo-50/50", "ring-2", "ring-indigo-300")
  }

  onDragLeave = (event) => {
    const column = event.target.closest(".kanban-column-body")
    if (!column || !this.dragCard) return
    if (column.contains(event.relatedTarget)) return
    column.classList.remove("bg-indigo-50/50", "ring-2", "ring-indigo-300")
  }

  onDrop = (event) => {
    event.preventDefault()
    const column = event.target.closest(".kanban-column-body")
    if (!column || !this.dragCard) return

    column.classList.remove("bg-indigo-50/50", "ring-2", "ring-indigo-300")

    const taskId = event.dataTransfer.getData("text/plain")
    const newStatus = column.dataset.status
    const insertBefore = this.getInsertBefore(column, event.clientY)

    fetch(column.dataset.moveUrl.replace(":id", taskId), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ status: newStatus, position: insertBefore ? [...column.children].indexOf(insertBefore) : column.children.length })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const card = this.element.querySelector(`[data-task-id="${taskId}"]`)
        if (card) {
          card.classList.remove("opacity-40", "scale-95")
          if (insertBefore) {
            column.insertBefore(card, insertBefore)
          } else {
            column.appendChild(card)
          }
          card.classList.add("transition-all", "duration-300")
          setTimeout(() => card.classList.remove("transition-all", "duration-300"), 300)
        }
      } else {
        this.dragCard.classList.remove("opacity-40", "scale-95")
      }
    })
    .catch(() => {
      if (this.dragCard) this.dragCard.classList.remove("opacity-40", "scale-95")
    })
  }

  getInsertBefore(column, mouseY) {
    const cards = column.querySelectorAll(".kanban-card:not(.opacity-40)")
    for (const card of cards) {
      const rect = card.getBoundingClientRect()
      if (mouseY < rect.top + rect.height / 2) return card
    }
    return null
  }
}
