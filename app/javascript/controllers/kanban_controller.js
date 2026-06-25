import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["column"]

  connect() {
    this.initDragAndDrop()
  }

  initDragAndDrop() {
    document.querySelectorAll(".kanban-card").forEach(card => {
      card.setAttribute("draggable", "true")
      card.addEventListener("dragstart", this.dragStart.bind(this))
      card.addEventListener("dragend", this.dragEnd.bind(this))
    })

    document.querySelectorAll(".kanban-column-body").forEach(column => {
      column.addEventListener("dragover", this.dragOver.bind(this))
      column.addEventListener("dragenter", this.dragEnter.bind(this))
      column.addEventListener("dragleave", this.dragLeave.bind(this))
      column.addEventListener("drop", this.drop.bind(this))
    })
  }

  dragStart(event) {
    event.dataTransfer.setData("text/plain", event.target.dataset.taskId)
    event.target.classList.add("opacity-50")
  }

  dragEnd(event) {
    event.target.classList.remove("opacity-50")
  }

  dragOver(event) {
    event.preventDefault()
  }

  dragEnter(event) {
    event.preventDefault()
    event.currentTarget.classList.add("bg-gray-50")
  }

  dragLeave(event) {
    event.currentTarget.classList.remove("bg-gray-50")
  }

  drop(event) {
    event.preventDefault()
    event.currentTarget.classList.remove("bg-gray-50")

    const taskId = event.dataTransfer.getData("text/plain")
    const newStatus = event.currentTarget.dataset.status
    const targetColumn = event.currentTarget

    fetch(targetColumn.dataset.moveUrl.replace(":id", taskId), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ status: newStatus, position: targetColumn.children.length })
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const card = document.querySelector(`[data-task-id="${taskId}"]`)
        if (card) {
          targetColumn.appendChild(card)
        }
      }
    })
  }
}
