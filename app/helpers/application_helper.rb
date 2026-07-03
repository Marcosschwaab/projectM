module ApplicationHelper
  def priority_badge(priority)
    return tag.span("—", class: "text-xs text-gray-400") if priority.blank?

    cfg = priority_config(priority.to_s)
    return tag.span(priority.to_s.humanize, class: "text-xs text-gray-500") unless cfg

    label = t("tasks.priorities.#{priority}", default: priority.to_s.humanize)

    svg = tag.svg class: "w-3 h-3 #{cfg[:icon_class]} flex-shrink-0", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24" do
      case cfg[:icon]
      when "arrow-up"
        tag.path "d": "M12 19V5m0 0l-7 7m7-7l7 7", "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2.5"
      when "arrow-down"
        tag.path "d": "M12 5v14m0 0l7-7m-7 7l-7-7", "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2.5"
      when "minus"
        tag.path "d": "M5 12h14", "stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2.5"
      end
    end

    tag.span class: "inline-flex items-center gap-1.5 text-xs font-medium #{cfg[:text_class]}" do
      concat(svg)
      concat(label)
    end
  end

  def status_badge(status)
    return tag.span("—", class: "text-xs text-gray-400") if status.blank?

    cfg = status_config(status.to_s)
    return tag.span(status.to_s.humanize, class: "text-xs text-gray-500") unless cfg

    label = t("tasks.statuses.#{status}", default: status.to_s.humanize)

    tag.span class: "inline-flex items-center px-1.5 py-0.5 rounded text-[11px] font-semibold leading-tight #{cfg[:lozenge]}" do
      concat(label)
    end
  end

  # Legacy CSS-only helpers (kept for backward compat with calendars, reports, etc.)
  def priority_badge_class(priority)
    cfg = priority_config(priority.to_s)
    cfg ? "#{cfg[:icon_class]} #{cfg[:text_class]}" : "text-gray-500 dark:text-gray-400"
  end
  alias_method :priority_class, :priority_badge_class

  def status_badge_class(status)
    cfg = status_config(status.to_s)
    cfg ? cfg[:lozenge] : "text-gray-500 dark:text-gray-400"
  end

  private

  def priority_config(priority)
    case priority
    when "urgent" then { icon: "arrow-up", icon_class: "text-red-500", text_class: "text-red-600 dark:text-red-400" }
    when "high"   then { icon: "arrow-up", icon_class: "text-orange-500", text_class: "text-orange-600 dark:text-orange-400" }
    when "medium" then { icon: "minus", icon_class: "text-amber-500", text_class: "text-amber-600 dark:text-amber-400" }
    when "low"    then { icon: "arrow-down", icon_class: "text-green-500", text_class: "text-green-600 dark:text-green-400" }
    else nil
    end
  end

  def status_config(status)
    case status
    when "done"        then { lozenge: "bg-emerald-500 text-white dark:bg-emerald-600" }
    when "in_review"   then { lozenge: "bg-violet-500 text-white dark:bg-violet-600" }
    when "in_progress" then { lozenge: "bg-blue-500 text-white dark:bg-blue-600" }
    when "todo"        then { lozenge: "bg-gray-400 text-white dark:bg-gray-500" }
    when "backlog"     then { lozenge: "bg-gray-200 text-gray-500 dark:bg-gray-600 dark:text-gray-300" }
    else                    { lozenge: "bg-gray-200 text-gray-600 dark:bg-gray-600 dark:text-gray-300" }
    end
  end

  def role_badge_class(role)
    case role.to_s
    when "admin" then "px-2 py-0.5 text-xs font-medium bg-purple-100 text-purple-700 rounded-full dark:bg-purple-900/30 dark:text-purple-400"
    when "manager" then "px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-700 rounded-full dark:bg-blue-900/30 dark:text-blue-400"
    else "px-2 py-0.5 text-xs font-medium bg-gray-100 text-gray-600 rounded-full dark:bg-gray-700 dark:text-gray-300"
    end
  end

  def cycle_status_badge_class(status)
    case status.to_s
    when "active" then "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
    when "completed" then "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
    when "draft" then "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
    when "cancelled" then "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
    else "bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
    end
  end

  def column_color(status)
    case status.to_s
    when "backlog" then "#6b7280"
    when "todo" then "#6366f1"
    when "in_progress" then "#3b82f6"
    when "in_review" then "#8b5cf6"
    when "done" then "#10b981"
    else "#6b7280"
    end
  end

  def project_status_color(status)
    case status.to_s
    when "on_track" then "#10b981"
    when "at_risk" then "#ef4444"
    when "behind" then "#f59e0b"
    when "on_hold" then "#6b7280"
    when "completed" then "#3b82f6"
    else "#6b7280"
    end
  end

  def project_gantt_color(project)
    case project.status.to_s
    when "on_track" then "bg-gradient-to-r from-green-500 to-emerald-400"
    when "at_risk" then "bg-gradient-to-r from-red-500 to-red-400"
    when "behind" then "bg-gradient-to-r from-yellow-500 to-yellow-400"
    when "on_hold" then "bg-gradient-to-r from-gray-400 to-gray-300"
    when "completed" then "bg-gradient-to-r from-blue-500 to-blue-400"
    else "bg-gradient-to-r from-indigo-500 to-indigo-400"
    end
  end

  def task_gantt_color(task)
    if task.status == "done"
      "bg-gradient-to-r from-green-500 to-emerald-400"
    else
      case task.status
      when "in_progress" then "bg-gradient-to-r from-blue-500 to-blue-400"
      when "in_review" then "bg-gradient-to-r from-purple-500 to-purple-400"
      when "todo" then "bg-gradient-to-r from-indigo-500 to-indigo-400"
      else "bg-gradient-to-r from-gray-400 to-gray-300"
      end
    end
  end

  def project_status_badge_class(status)
    case status.to_s
    when "on_track" then "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
    when "at_risk" then "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
    when "behind" then "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400"
    when "on_hold" then "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
    when "completed" then "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
    else "bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
    end
  end

  def project_color(project)
    case project.status.to_s
    when "on_track" then "bg-green-500"
    when "at_risk" then "bg-red-500"
    when "behind" then "bg-amber-500"
    when "on_hold" then "bg-gray-400"
    when "completed" then "bg-blue-500"
    else "bg-indigo-500"
    end
  end

  def group_link(current_group, value, label)
    if value.nil?
      path = my_tasks_path(request.query_parameters.except(:group_by))
    elsif value == current_group
      path = my_tasks_path(request.query_parameters.except(:group_by))
    else
      path = my_tasks_path(request.query_parameters.merge(group_by: value))
    end
    active = current_group == value
    link_to label, path, class: "px-2.5 py-1.5 text-xs font-medium rounded-md transition-colors #{active ? 'bg-white dark:bg-gray-600 shadow-sm text-gray-900 dark:text-gray-100' : 'text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-300'}"
  end

  def group_label(group_key, group_by)
    case group_by
    when "project"
      group_key[1]
    when "priority"
      priority_name = group_key.is_a?(String) ? group_key : "none"
      t("tasks.priorities.#{priority_name}", default: priority_name.humanize)
    when "status"
      status_name = group_key.is_a?(String) ? group_key : "none"
      t("tasks.statuses.#{status_name}", default: status_name.humanize)
    else
      group_key.to_s
    end
  end
end
