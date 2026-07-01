import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["header", "grid", "row"]
  static values = { start: String, end: String }

  connect() {
    this.render()
    window.addEventListener("resize", this.reposition)
  }

  disconnect() {
    window.removeEventListener("resize", this.reposition)
  }

  reposition = () => {
    this.positionBars()
  }

  render() {
    const start = new Date(this.startValue)
    const end = new Date(this.endValue)
    const totalDays = Math.max(Math.ceil((end - start) / (1000 * 60 * 60 * 24)), 1)
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    this.renderHeader(start, totalDays)
    this.renderGrid(start, totalDays, today)
    this.positionBars()
    this.drawTodayLine(start, totalDays, today)
  }

  renderHeader(start, totalDays) {
    if (!this.hasHeaderTarget) return

    const endDate = new Date(start)
    endDate.setDate(endDate.getDate() + totalDays)
    const locale = document.documentElement.lang || "en"

    let months = ""
    let weeks = ""
    let current = new Date(start)
    let currentMonth = -1
    let currentYear = -1

    while (current < endDate) {
      const m = current.getMonth()
      const y = current.getFullYear()
      if (m !== currentMonth || y !== currentYear) {
        const monthEnd = new Date(y, m + 1, 1)
        const monthDays = Math.min(
          Math.ceil((monthEnd - current) / (1000 * 60 * 60 * 24)),
          totalDays - Math.round((current - start) / (1000 * 60 * 60 * 24))
        )
        const w = (monthDays / totalDays) * 100
        months += `<div class="text-xs text-gray-500 dark:text-gray-400 px-1 truncate font-semibold" style="width:${w}%;flex-shrink:0;border-left:1px solid #e5e7eb;border-left-color:color-mix(in srgb, currentColor 20%, transparent)">${current.toLocaleDateString(locale, { month: "long", year: "numeric" })}</div>`
        currentMonth = m
        currentYear = y
      }

      const dow = current.getDay()
      if (dow === 1) {
        const weekEnd = new Date(current)
        weekEnd.setDate(weekEnd.getDate() + 7)
        const weekDays = Math.min(
          Math.ceil((weekEnd - current) / (1000 * 60 * 60 * 24)),
          totalDays - Math.round((current - start) / (1000 * 60 * 60 * 24))
        )
        const w = (weekDays / totalDays) * 100
        weeks += `<div class="text-[10px] text-gray-400 dark:text-gray-500 px-0.5 truncate border-l border-gray-200 dark:border-gray-700" style="width:${w}%;flex-shrink:0">${current.toLocaleDateString(locale, { day: "numeric", month: "short" })}</div>`
      }

      current.setDate(current.getDate() + 1)
    }

    this.headerTarget.innerHTML = `<div class="flex border-b border-gray-200 dark:border-gray-700 h-4 items-end pb-0.5">${months}</div><div class="flex h-4 items-end pb-0.5">${weeks}</div>`
  }

  renderGrid(start, totalDays, today) {
    if (!this.hasGridTarget) return

    const endDate = new Date(start)
    endDate.setDate(endDate.getDate() + totalDays)

    let html = ""
    let current = new Date(start)
    let weekIdx = 0
    const todayLeft = ((today - start) / (1000 * 60 * 60 * 24) / totalDays) * 100

    while (current < endDate) {
      const weekEnd = new Date(current)
      weekEnd.setDate(weekEnd.getDate() + (7 - current.getDay()))
      const weekDays = Math.min(
        Math.ceil((weekEnd - current) / (1000 * 60 * 60 * 24)),
        totalDays - Math.round((current - start) / (1000 * 60 * 60 * 24))
      )
      const w = (weekDays / totalDays) * 100

      const colLeft = ((current - start) / (1000 * 60 * 60 * 24) / totalDays) * 100
      const hasToday = todayLeft >= colLeft && todayLeft < colLeft + (weekDays / totalDays) * 100

      html += `<div class="${weekIdx % 2 === 1 ? "bg-gray-50 dark:bg-gray-700/20" : ""} ${hasToday ? "bg-indigo-50/30 dark:bg-indigo-900/10" : ""}" style="width:${w}%;flex-shrink:0;border-left:1px solid #f3f4f6;dark:border-left-color:#374151"></div>`

      weekIdx++
      current = new Date(weekEnd)
      current.setDate(current.getDate() + 1)
    }

    this.gridTarget.innerHTML = html
  }

  positionBars() {
    this.rowTargets.forEach(row => {
      const bar = row.querySelector("[data-gantt-target='bar']")
      if (!bar) return

      const start = new Date(this.startValue)
      const end = new Date(this.endValue)
      const totalDays = Math.max(Math.ceil((end - start) / (1000 * 60 * 60 * 24)), 1)
      const totalMs = totalDays * 24 * 60 * 60 * 1000

      const itemStart = new Date(row.dataset.ganttStart)
      const itemEnd = new Date(row.dataset.ganttEnd)
      const left = Math.max(((itemStart - start) / totalMs) * 100, 0)
      const width = Math.max(((itemEnd - itemStart) / totalMs) * 100, 1.5)

      bar.style.left = `${Math.min(left, 100)}%`
      bar.style.width = `${Math.min(width, 100 - left)}%`
    })
  }

  drawTodayLine(start, totalDays, today) {
    const msSinceStart = today - start
    const totalMs = totalDays * 24 * 60 * 60 * 1000
    if (msSinceStart < 0 || msSinceStart > totalMs) return

    const left = (msSinceStart / totalMs) * 100
    const container = this.element.querySelector(".gantt-bars-container")
    if (!container) return

    const el = document.createElement("div")
    el.className = "absolute top-0 bottom-0 pointer-events-none"
    el.style.left = `${left}%`
    el.style.width = "2px"
    el.style.background = "repeating-linear-gradient(to bottom, #ef4444 0px, #ef4444 4px, transparent 4px, transparent 8px)"
    el.style.zIndex = "20"

    const dot = document.createElement("div")
    dot.className = "absolute -top-1 -left-1.5 w-3 h-3 rounded-full bg-red-500 border-2 border-white dark:border-gray-800"
    el.appendChild(dot)

    container.appendChild(el)
  }
}
