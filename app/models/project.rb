class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :assignee, class_name: "User", optional: true

  validates :name, presence: true

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }
  enum :status, { on_track: 0, at_risk: 1, behind: 2, on_hold: 3, completed: 4 }

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
end
