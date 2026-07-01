import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid", "widget", "dragHandle", "settingsPanel"]

  connect() {
    this.dragData = null
    this.boundMouseMove = this.onMouseMove.bind(this)
    this.boundMouseUp = this.onMouseUp.bind(this)
  }

  startDrag(event) {
    const handle = event.currentTarget
    const widget = handle.closest("[data-dashboard-target='widget']")
    if (!widget) return

    this.dragData = {
      widget: widget,
      startX: event.clientX,
      startY: event.clientY,
      offsetY: event.clientY - widget.getBoundingClientRect().top,
      placeholder: this.createPlaceholder(widget)
    }

    document.addEventListener("mousemove", this.boundMouseMove)
    document.addEventListener("mouseup", this.boundMouseUp)

    widget.style.width = widget.offsetWidth + "px"
    widget.classList.add("dragging")
  }

  onMouseMove(event) {
    if (!this.dragData) return

    const grid = this.gridTarget
    const widgets = [...grid.querySelectorAll("[data-dashboard-target='widget']:not(.dragging)")]

    const widget = this.dragData.widget
    widget.style.transform = `translateY(${event.clientY - this.dragData.startY}px)`

    const widgetRect = widget.getBoundingClientRect()
    const widgetMidY = widgetRect.top + widgetRect.height / 2

    let inserted = false
    for (const other of widgets) {
      const otherRect = other.getBoundingClientRect()
      const otherMidY = otherRect.top + otherRect.height / 2
      const parent = other.parentElement

      if (widgetMidY < otherMidY) {
        parent.parentElement.insertBefore(widget.parentElement, parent)
        inserted = true
        break
      }
    }

    if (!inserted) {
      const lastParent = widgets.length > 0 ? widgets[widgets.length - 1].parentElement : null
      if (lastParent) {
        lastParent.parentElement.appendChild(widget.parentElement)
      }
    }
  }

  onMouseUp() {
    if (!this.dragData) return

    const widget = this.dragData.widget
    widget.classList.remove("dragging")
    widget.style.transform = ""
    widget.style.width = ""

    if (this.dragData.placeholder) {
      this.dragData.placeholder.remove()
    }

    document.removeEventListener("mousemove", this.boundMouseMove)
    document.removeEventListener("mouseup", this.boundMouseUp)

    this.persistOrder()
    this.dragData = null
  }

  createPlaceholder(widget) {
    const ph = document.createElement("div")
    ph.className = "dashboard-placeholder"
    ph.style.cssText = "height:" + widget.offsetHeight + "px;border:2px dashed #6366f1;border-radius:12px;margin-bottom:0;opacity:0.5"
    widget.parentElement.insertAdjacentElement("afterend", ph)
    return ph
  }

  persistOrder() {
    const orderedIds = [...this.gridTarget.querySelectorAll("[data-dashboard-target='widget']")].map(el => el.dataset.widgetId)
    fetch("/dashboard/widgets/reorder", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ ordered_ids: orderedIds })
    })
  }

  toggleSettings(event) {
    const panel = event.currentTarget.closest("[data-dashboard-target='widget']")
      ?.querySelector("[data-dashboard-target='settingsPanel']")
    if (!panel) return
    panel.classList.toggle("hidden")

    document.querySelectorAll("[data-dashboard-target='settingsPanel']").forEach(p => {
      if (p !== panel) p.classList.add("hidden")
    })
  }

  removeWidget(event) {
    const widget = event.currentTarget.closest("[data-dashboard-target='widget']")
    if (!widget) return

    const id = widget.dataset.widgetId
    fetch(`/dashboard/widgets/${id}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      }
    }).then(response => {
      if (response.ok) {
        widget.parentElement.remove()
      }
    })
  }

  addWidget() {
    const types = this.constructor.widgetTypes
    const grid = this.gridTarget
    const existing = [...grid.querySelectorAll("[data-dashboard-target='widget']")].map(el => el.dataset.widgetType)

    const available = types.filter(t => !existing.includes(t))
    if (available.length === 0) {
      alert("All widget types are already on your dashboard.")
      return
    }

    const chooser = document.createElement("div")
    chooser.className = "fixed inset-0 bg-black/40 flex items-center justify-center z-50"
    chooser.innerHTML = `
      <div class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl p-6 w-96 max-w-full mx-4">
        <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">${this.constructor.i18n.addWidget}</h3>
        <div class="space-y-2 max-h-80 overflow-y-auto">
          ${available.map(type => `
            <button data-type="${type}" class="add-widget-option w-full text-left px-4 py-3 rounded-xl border border-gray-200 dark:border-gray-700 hover:bg-indigo-50 dark:hover:bg-indigo-900/20 hover:border-indigo-300 dark:hover:border-indigo-600 transition-colors text-sm font-medium text-gray-700 dark:text-gray-300">
              ${this.constructor.i18n[type] || type}
            </button>
          `).join("")}
        </div>
        <button class="cancel-add-widget mt-4 w-full px-4 py-2 text-sm text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300">
          Cancel
        </button>
      </div>
    `

    document.body.appendChild(chooser)

    chooser.querySelectorAll(".add-widget-option").forEach(btn => {
      btn.addEventListener("click", () => {
        const type = btn.dataset.type
        fetch("/dashboard/widgets", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
          },
          body: JSON.stringify({ dashboard_widget: { widget_type: type } })
        }).then(r => r.json()).then(data => {
          if (data.id) {
            location.reload()
          }
        })
        chooser.remove()
      })
    })

    chooser.querySelector(".cancel-add-widget").addEventListener("click", () => chooser.remove())
    chooser.addEventListener("click", (e) => { if (e.target === chooser) chooser.remove() })
  }

  static widgetTypes = [
    "stats", "completion_rate", "tasks_by_status", "tasks_by_priority",
    "project_status", "upcoming_deadlines", "my_tasks_list", "okr_progress",
    "kpis_summary", "recent_activity", "projects_overview", "timeline",
    "overdue_tasks", "due_this_week"
  ]

  static i18n = {
    addWidget: "Add Widget",
    stats: "Statistics",
    completion_rate: "Completion Rate",
    tasks_by_status: "Tasks by Status",
    tasks_by_priority: "Tasks by Priority",
    project_status: "Project Status",
    upcoming_deadlines: "Upcoming Deadlines",
    my_tasks_list: "My Tasks",
    okr_progress: "OKR Progress",
    kpis_summary: "KPIs Summary",
    recent_activity: "Recent Activity",
    projects_overview: "Projects Overview",
    timeline: "Timeline",
    overdue_tasks: "Overdue Tasks",
    due_this_week: "Due This Week"
  }
}
