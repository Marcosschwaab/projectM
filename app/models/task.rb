class Task < ApplicationRecord
  include Webhookable

  belongs_to :project
  delegate :organization, to: :project
  belongs_to :assignee, class_name: "User", optional: true

  has_many :checklist_items, -> { order(position: :asc) }, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :activity_logs, as: :trackable, dependent: :nullify
  has_many_attached :files

  has_many :task_dependencies, dependent: :destroy
  has_many :dependencies, through: :task_dependencies, source: :dependency
  has_many :incoming_dependencies, class_name: "TaskDependency", foreign_key: :dependency_id, dependent: :destroy
  has_many :dependent_tasks, through: :incoming_dependencies, source: :task

  validates :title, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }
  enum :status, { backlog: 0, todo: 1, in_progress: 2, in_review: 3, done: 4 }

  scope :by_status, -> { order(status: :asc, position: :asc) }

  private

  def dispatch_webhooks_for_create
    dispatch_webhook_event("task.created", webhook_payload_base)
  end

  def dispatch_webhooks_for_update
    dispatch_webhook_event("task.updated", webhook_payload_base)
  end

  def serialized_for_webhook
    {
      id: id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      assignee: assignee&.name,
      due_date: due_date,
      project: project.name
    }
  end
end
