import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["column"]
  static values = { projectId: Number }

  connect() {
    this.dragCard = null
    this.dragPlaceholder = null
    this.autoScrollInterval = null
    this._movingTaskIds = new Set()
    this.bindEvents()
    this.subscribeToChannel()
    this.updateColumnCounts()
  }

  disconnect() {
    this.unbindEvents()
    this.unsubscribe()
    this.stopAutoScroll()
    this.removePlaceholder()
  }

  subscribeToChannel() {
    if (!this.hasProjectIdValue) return
    this.subscription = consumer.subscriptions.create(
      { channel: "TasksChannel", project_id: this.projectIdValue },
      {
        received: (data) => {
          if (data.action === "move") {
            const taskId = String(data.task_id)
            if (this._movingTaskIds.has(taskId)) return
            const card = this.element.querySelector(`[data-task-id="${taskId}"]`)
            if (card) card.remove()
            const column = this.element.querySelector(`.kanban-column-body[data-status="${data.status}"]`)
            if (column) column.insertAdjacentHTML("beforeend", data.html)
            this.updateColumnCounts()
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
    requestAnimationFrame(() => card.classList.add("opacity-30", "scale-95"))
    card.style.transition = "opacity 0.2s, transform 0.2s"
  }

  onDragEnd = () => {
    if (this.dragCard) {
      this.dragCard.classList.remove("opacity-30", "scale-95")
    }
    this.columnTargets.forEach(col => col.classList.remove("bg-indigo-50/50", "ring-2", "ring-indigo-300"))
    this.removePlaceholder()
    this.stopAutoScroll()
    this.dragCard = null
  }

  onDragOver = (event) => {
    const column = event.target.closest(".kanban-column-body")
    if (!column || !this.dragCard) return
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"

    const insertBefore = this.getInsertBefore(column, event.clientY)
    this.showPlaceholder(column, insertBefore)
    this.handleAutoScroll(event)
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
    this.removePlaceholder()
  }

  onDrop = (event) => {
    event.preventDefault()
    const column = event.target.closest(".kanban-column-body")
    if (!column) return

    column.classList.remove("bg-indigo-50/50", "ring-2", "ring-indigo-300")
    this.removePlaceholder()
    this.stopAutoScroll()

    const taskId = event.dataTransfer.getData("text/plain")
    const newStatus = column.dataset.status
    const insertBefore = this.getInsertBefore(column, event.clientY)

    this._movingTaskIds.add(taskId)

    const card = this.element.querySelector(`[data-task-id="${taskId}"]`)
    if (!card) {
      this._movingTaskIds.delete(taskId)
      return
    }

    card.classList.remove("opacity-30", "scale-95")

    if (insertBefore) {
      column.insertBefore(card, insertBefore)
    } else {
      column.appendChild(card)
    }

    card.classList.add("kanban-card-inserted")
    setTimeout(() => card.classList.remove("kanban-card-inserted"), 400)
    this.updateColumnCounts()

    fetch(column.dataset.moveUrl.replace(":id", taskId), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ status: newStatus, position: [...column.querySelectorAll(".kanban-card")].indexOf(card) })
    })
    .then(response => response.json())
    .then(data => {
      if (!data.success) {
        location.reload()
      }
      this._movingTaskIds.delete(taskId)
    })
    .catch(() => {
      this._movingTaskIds.delete(taskId)
    })
  }

  getInsertBefore(column, mouseY) {
    const cards = column.querySelectorAll(".kanban-card:not(.opacity-30)")
    for (const card of cards) {
      const rect = card.getBoundingClientRect()
      if (mouseY < rect.top + rect.height / 2) return card
    }
    return null
  }

  showPlaceholder(column, insertBefore) {
    const existing = column.querySelector(".kanban-placeholder")
    if (existing) existing.remove()

    const ph = document.createElement("div")
    ph.className = "kanban-placeholder"
    ph.style.cssText = "height:4px;margin:4px 0;border-radius:4px;background:linear-gradient(90deg,#6366f1,#8b5cf6);flex-shrink:0"

    if (insertBefore) {
      column.insertBefore(ph, insertBefore)
    } else {
      column.appendChild(ph)
    }
    this.dragPlaceholder = ph
  }

  removePlaceholder() {
    if (this.dragPlaceholder) {
      this.dragPlaceholder.remove()
      this.dragPlaceholder = null
    }
  }

  handleAutoScroll(event) {
    const rect = this.element.getBoundingClientRect()
    const threshold = 60
    if (event.clientX < rect.left + threshold) {
      this.startAutoScroll(-20)
    } else if (event.clientX > rect.right - threshold) {
      this.startAutoScroll(20)
    } else {
      this.stopAutoScroll()
    }
  }

  startAutoScroll(speed) {
    if (this.autoScrollInterval) return
    this.autoScrollInterval = setInterval(() => {
      this.element.scrollLeft += speed
    }, 16)
  }

  stopAutoScroll() {
    if (this.autoScrollInterval) {
      clearInterval(this.autoScrollInterval)
      this.autoScrollInterval = null
    }
  }

  updateColumnCounts() {
    this.columnTargets.forEach(col => {
      const count = col.querySelectorAll(".kanban-card").length
      const badge = col.closest(".kanban-column")?.querySelector(".kanban-count")
      if (badge) badge.textContent = count
      const emptyState = col.querySelector(".kanban-empty-state")
      if (emptyState) emptyState.classList.toggle("hidden", count > 0)
    })
  }

  toggleQuickAdd(event) {
    const column = event.currentTarget.closest(".kanban-column")
    if (!column) return
    const form = column.querySelector(".kanban-quick-add")
    if (!form) return
    form.classList.toggle("hidden")
    if (!form.classList.contains("hidden")) {
      const input = form.querySelector(".kanban-quick-input")
      if (input) setTimeout(() => input.focus(), 50)
    }
  }

  hideQuickAdd(event) {
    const form = event.currentTarget.closest(".kanban-quick-add")
    if (form) {
      form.classList.add("hidden")
      const input = form.querySelector(".kanban-quick-input")
      if (input) input.value = ""
    }
  }

  submitQuickAdd(event) {
    const form = event.target
    const input = form.querySelector(".kanban-quick-input")
    if (!input?.value?.trim()) {
      event.preventDefault()
      return
    }
  }

  cancelQuickAdd(event) {
    if (event.key === "Escape") {
      const form = event.target.closest(".kanban-quick-add")
      if (form) form.classList.add("hidden")
    }
  }
}
