module ApplicationHelper
  def priority_badge_class(priority)
    case priority
    when "urgent" then "bg-red-100 text-red-700"
    when "high" then "bg-orange-100 text-orange-700"
    when "medium" then "bg-blue-100 text-blue-700"
    else "bg-gray-100 text-gray-700"
    end
  end

  def status_badge_class(status)
    case status
    when "done" then "bg-green-100 text-green-700"
    when "in_review" then "bg-purple-100 text-purple-700"
    when "in_progress" then "bg-blue-100 text-blue-700"
    when "todo" then "bg-yellow-100 text-yellow-700"
    else "bg-gray-100 text-gray-700"
    end
  end
end
