class DashboardWidget < ApplicationRecord
  WIDGET_TYPES = %w[
    stats completion_rate tasks_by_status tasks_by_priority
    project_status upcoming_deadlines my_tasks_list okr_progress
    kpis_summary recent_activity projects_overview timeline
    overdue_tasks due_this_week
  ].freeze

  WIDGET_WIDTHS = [1, 2, 3].freeze

  belongs_to :user

  validates :widget_type, presence: true, inclusion: { in: WIDGET_TYPES }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :width, presence: true, inclusion: { in: WIDGET_WIDTHS }
  validates :visible, inclusion: { in: [true, false] }

  scope :visible, -> { where(visible: true) }
  scope :ordered, -> { order(position: :asc) }

  def self.defaults_for(user)
    attrs_list = [
      { widget_type: "stats", position: 0, width: 3, settings: {} },
      { widget_type: "completion_rate", position: 1, width: 1, settings: { "limit" => 5 } },
      { widget_type: "tasks_by_status", position: 2, width: 1, settings: {} },
      { widget_type: "tasks_by_priority", position: 3, width: 1, settings: {} },
      { widget_type: "upcoming_deadlines", position: 4, width: 1, settings: {} },
      { widget_type: "my_tasks_list", position: 5, width: 1, settings: { "limit" => 5 } },
      { widget_type: "project_status", position: 6, width: 1, settings: {} },
      { widget_type: "recent_activity", position: 7, width: 2, settings: { "limit" => 8 } },
      { widget_type: "okr_progress", position: 8, width: 1, settings: {} },
      { widget_type: "kpis_summary", position: 9, width: 1, settings: { "limit" => 4 } },
      { widget_type: "timeline", position: 10, width: 3, settings: {} },
      { widget_type: "projects_overview", position: 11, width: 2, settings: { "limit" => 6 } },
    ]
    attrs_list.each { |attrs| find_or_create_by!(user: user, widget_type: attrs[:widget_type]) { |w| w.assign_attributes(attrs) } }
    where(user: user).ordered
  end
end
