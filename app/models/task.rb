class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assignee, class_name: "User", optional: true

  has_many :checklist_items, -> { order(position: :asc) }, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :activity_logs, as: :trackable, dependent: :nullify

  validates :title, presence: true

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }
  enum :status, { backlog: 0, todo: 1, in_progress: 2, in_review: 3, done: 4 }

  scope :by_status, -> { order(status: :asc, position: :asc) }
end
