class Task < ApplicationRecord
  include Webhookable

  RECURRENCE_RULES = %w[daily weekdays weekly biweekly monthly yearly].freeze

  belongs_to :project
  delegate :organization, to: :project
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :recurring_parent, class_name: "Task", optional: true
  has_many :recurring_children, class_name: "Task", foreign_key: :recurring_parent_id, dependent: :nullify

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
  validates :recurrence_rule, inclusion: { in: RECURRENCE_RULES, allow_nil: true, allow_blank: true }

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }
  enum :status, { backlog: 0, todo: 1, in_progress: 2, in_review: 3, done: 4 }

  scope :by_status, -> { order(status: :asc, position: :asc) }
  scope :recurring, -> { where.not(recurrence_rule: [nil, ""]) }
  scope :recurring_active, -> { recurring.where("recurrence_end_date IS NULL OR recurrence_end_date > ?", Date.today) }

  def recurring?
    recurrence_rule.present?
  end

  def next_due_date
    return nil unless recurring? && due_date.present?
    return nil if recurrence_end_date.present? && recurrence_end_date <= Date.today

    calculate_next_due
  end

  def recurrence_label
    return nil unless recurring?
    I18n.t("tasks.recurrence.#{recurrence_rule}", default: recurrence_rule.humanize)
  end

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

  def calculate_next_due
    case recurrence_rule
    when "daily"    then due_date + 1.day
    when "weekdays" then next_weekday(due_date + 1.day)
    when "weekly"   then due_date + 7.days
    when "biweekly" then due_date + 14.days
    when "monthly"  then due_date.next_month
    when "yearly"   then due_date.next_year
    else nil
    end
  end

  def next_weekday(date)
    date += 1.day while date.saturday? || date.sunday?
    date
  end
end
