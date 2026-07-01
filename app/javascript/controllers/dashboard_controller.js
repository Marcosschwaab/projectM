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

    const rect = widget.getBoundingClientRect()
    this.dragData = {
      widget: widget,
      startX: event.clientX,
      startY: event.clientY,
      widgetStartY: rect.top,
      placeholder: this.createPlaceholder(widget),
      widgetRects: this.captureWidgetRects()
    }

    document.addEventListener("mousemove", this.boundMouseMove)
    document.addEventListener("mouseup", this.boundMouseUp)

    widget.style.width = rect.width + "px"
    widget.style.height = rect.height + "px"
    widget.classList.add("dragging")
  }

  captureWidgetRects() {
    const grid = this.gridTarget
    return [...grid.querySelectorAll(".dashboard-grid-item")].map(el => ({
      el,
      rect: el.getBoundingClientRect()
    }))
  }

  onMouseMove(event) {
    if (!this.dragData) return

    const grid = this.gridTarget
    const widget = this.dragData.widget
    const dy = event.clientY - this.dragData.startY
    widget.style.transform = `translateY(${dy}px)`

    const items = [...grid.querySelectorAll(".dashboard-grid-item")]
    const draggedItem = widget.parentElement
    const widgetMidY = this.dragData.widgetStartY + dy + widget.offsetHeight / 2

    let insertBefore = null
    for (const item of items) {
      if (item === draggedItem) continue
      const rect = item.getBoundingClientRect()
      const itemMidY = rect.top + rect.height / 2
      if (widgetMidY < itemMidY) {
        insertBefore = item
        break
      }
    }

    if (insertBefore && draggedItem.nextElementSibling !== insertBefore) {
      grid.insertBefore(draggedItem, insertBefore)
    } else if (!insertBefore) {
      grid.appendChild(draggedItem)
    }
  }

  onMouseUp() {
    if (!this.dragData) return

    const widget = this.dragData.widget
    widget.classList.remove("dragging")
    widget.style.transform = ""
    widget.style.width = ""
    widget.style.height = ""

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
    ph.className = "dashboard-grid-item dashboard-placeholder col-span-1 lg:col-span-1"
    ph.style.height = widget.offsetHeight + "px"
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
        const wrapper = widget.parentElement
        wrapper.style.transition = "all 0.3s cubic-bezier(0.4,0,0.2,1)"
        wrapper.style.transform = "scale(0.95)"
        wrapper.style.opacity = "0"
        wrapper.style.maxHeight = "0"
        wrapper.style.marginBottom = "0"
        wrapper.style.overflow = "hidden"
        setTimeout(() => wrapper.remove(), 300)
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

  startResize(event) {
    const handle = event.currentTarget
    const widget = handle.closest("[data-dashboard-target='widget']")
    if (!widget) return

    this.resizeData = {
      widget: widget,
      startX: event.clientX,
      currentWidth: parseInt(widget.dataset.widgetWidth) || 1,
      overlay: this.createResizeOverlay(widget)
    }

    document.addEventListener("mousemove", this.boundResizeMouseMove)
    document.addEventListener("mouseup", this.boundResizeMouseUp)
    document.body.classList.add("resizing")

    event.preventDefault()
  }

  boundResizeMouseMove = this.onResizeMouseMove.bind(this)
  boundResizeMouseUp = this.onResizeMouseUp.bind(this)

  onResizeMouseMove(event) {
    if (!this.resizeData) return

    const grid = this.gridTarget
    const gridRect = grid.getBoundingClientRect()
    const gridLeft = gridRect.left
    const gridWidth = gridRect.width
    const colWidth = gridWidth / 3

    const widgetLeft = this.resizeData.widget.getBoundingClientRect().left
    const mouseOffsetFromWidgetLeft = event.clientX - widgetLeft

    const colsFromLeft = mouseOffsetFromWidgetLeft / colWidth

    let newWidth
    if (colsFromLeft < 1.2) newWidth = 1
    else if (colsFromLeft < 2.3) newWidth = 2
    else newWidth = 3

    newWidth = Math.max(1, Math.min(3, newWidth))

    if (newWidth !== this.resizeData.currentWidth) {
      this.resizeData.currentWidth = newWidth
      this.updateResizeOverlay(newWidth)
    }
  }

  onResizeMouseUp() {
    if (!this.resizeData) return

    this.removeResizeOverlay()
    document.removeEventListener("mousemove", this.boundResizeMouseMove)
    document.removeEventListener("mouseup", this.boundResizeMouseUp)
    document.body.classList.remove("resizing")

    const newWidth = this.resizeData.currentWidth
    const widget = this.resizeData.widget
    const id = widget.dataset.widgetId
    const oldWidth = parseInt(widget.dataset.widgetWidth)

    this.resizeData = null

    if (newWidth === oldWidth) return

    fetch(`/dashboard/widgets/${id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ dashboard_widget: { width: newWidth } })
    })
    .then(response => {
      if (response.ok) {
        widget.dataset.widgetWidth = newWidth
        const wrapper = widget.parentElement
        wrapper.className = wrapper.className
          .replace(/lg:col-span-\d+/g, "")
          .replace(/col-span-\d+/g, "")
        wrapper.classList.add(`lg:col-span-${newWidth}`)
        if (newWidth === 1) wrapper.classList.add("col-span-1")
        this.updateSettingsButtons(widget, newWidth)
        this.animateSizeChange(widget)
      }
    })
  }

  createResizeOverlay(widget) {
    const overlay = document.createElement("div")
    overlay.className = "dashboard-resize-overlay"
    overlay.style.cssText = "position:absolute;inset:0;z-index:40;pointer-events:none;border-radius:12px;transition:all 0.1s ease"
    widget.appendChild(overlay)
    return overlay
  }

  updateResizeOverlay(width) {
    if (!this.resizeData?.overlay) return
    const colors = { 1: "rgba(99,102,241,0.08)", 2: "rgba(99,102,241,0.12)", 3: "rgba(99,102,241,0.16)" }
    const labels = { 1: "1 col", 2: "2 cols", 3: "3 cols" }
    this.resizeData.overlay.style.background = colors[width] || "transparent"
    this.resizeData.overlay.style.boxShadow = "inset 0 0 0 2px rgba(99,102,241,0.4)"
    this.resizeData.overlay.textContent = ""
    const label = document.createElement("span")
    label.style.cssText = "position:absolute;bottom:8px;right:28px;font-size:11px;font-weight:600;color:#6366f1;background:white;padding:2px 8px;border-radius:6px;box-shadow:0 1px 3px rgba(0,0,0,0.1)"
    label.textContent = labels[width] || ""
    this.resizeData.overlay.appendChild(label)
  }

  removeResizeOverlay() {
    if (this.resizeData?.overlay) {
      this.resizeData.overlay.remove()
    }
  }

  setWidth(event) {
    const btn = event.currentTarget
    const widget = btn.closest("[data-dashboard-target='widget']")
    if (!widget) return

    const newWidth = parseInt(btn.dataset.width)
    const id = widget.dataset.widgetId

    fetch(`/dashboard/widgets/${id}`, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ dashboard_widget: { width: newWidth } })
    })
    .then(response => {
      if (response.ok) {
        widget.dataset.widgetWidth = newWidth
        const wrapper = widget.parentElement
        wrapper.className = wrapper.className
          .replace(/lg:col-span-\d+/g, "")
          .replace(/col-span-\d+/g, "")
        wrapper.classList.add(`lg:col-span-${newWidth}`)
        if (newWidth === 1) wrapper.classList.add("col-span-1")
        this.updateSettingsButtons(widget, newWidth)
        this.animateSizeChange(widget)
      }
    })
  }

  animateSizeChange(widget) {
    widget.classList.remove("widget-size-change")
    void widget.offsetWidth
    widget.classList.add("widget-size-change")
    widget.addEventListener("animationend", () => {
      widget.classList.remove("widget-size-change")
    }, { once: true })
  }

  updateSettingsButtons(widget, width) {
    const buttons = widget.querySelectorAll("[data-dashboard-target='settingsPanel'] [data-width]")
    buttons.forEach(btn => {
      const w = parseInt(btn.dataset.width)
      if (w === width) {
        btn.className = "flex-1 px-3 py-2 text-xs font-medium rounded-lg border transition-colors bg-indigo-50 border-indigo-300 text-indigo-700 dark:bg-indigo-900/30 dark:border-indigo-600 dark:text-indigo-300"
      } else {
        btn.className = "flex-1 px-3 py-2 text-xs font-medium rounded-lg border transition-colors border-gray-200 text-gray-600 hover:bg-gray-50 dark:border-gray-700 dark:text-gray-400 dark:hover:bg-gray-700"
      }
    })
  }

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
