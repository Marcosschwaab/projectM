class KanbanColumn < ApplicationRecord
  DEFAULT_COLUMNS = [
    { label: "Backlog",     status: "backlog",     color: "#6b7280" },
    { label: "To Do",       status: "todo",        color: "#6366f1" },
    { label: "In Progress", status: "in_progress", color: "#3b82f6" },
    { label: "In Review",   status: "in_review",   color: "#8b5cf6" },
    { label: "Done",        status: "done",        color: "#10b981" },
  ].freeze

  belongs_to :project

  validates :label, :status, :position, :color, presence: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position) }
end
