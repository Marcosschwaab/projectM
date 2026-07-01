module ApplicationHelper
  def priority_badge_class(priority)
    case priority.to_s
    when "urgent" then "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400"
    when "high" then "bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400"
    when "medium" then "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
    else "bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
    end
  end

  alias_method :priority_class, :priority_badge_class

  def status_badge_class(status)
    case status.to_s
    when "done" then "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
    when "in_review" then "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400"
    when "in_progress" then "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400"
    when "todo" then "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400"
    else "bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
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
end
