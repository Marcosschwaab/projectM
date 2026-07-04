class Project < ApplicationRecord
  CATEGORIES = %w[software marketing infrastructure business other].freeze
  APPROVAL_ROLES = %w[sponsor manager responsible].freeze

  belongs_to :organization
  belongs_to :assignee, class_name: "User", optional: true
  belongs_to :sponsor, class_name: "User", optional: true
  belongs_to :manager, class_name: "User", optional: true

  has_many :tasks, dependent: :destroy
  has_one :strategic_canvas, dependent: :destroy
  has_many :objectives, dependent: :nullify
  has_many :kpis, dependent: :destroy
  has_many :project_members, dependent: :destroy
  has_many :members, through: :project_members, source: :user
  has_many :project_matrices, dependent: :destroy
  has_many :risks, dependent: :destroy
  has_many :kanban_columns, -> { ordered }, dependent: :destroy, inverse_of: :project
  has_many :custom_field_values, as: :customizable, dependent: :destroy
  accepts_nested_attributes_for :custom_field_values

  after_create :create_default_kanban_columns

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "must be a valid hex color" }, allow_blank: true
  validates :category, length: { maximum: 100 }, allow_blank: true

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }
  enum :status, { on_track: 0, at_risk: 1, behind: 2, on_hold: 3, completed: 4 }

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def approval_role_list
    (approval_roles || []) + (approval_all_team ? ["all_team"] : [])
  end

  def can_approve?(user)
    return true if approval_all_team && members.include?(user)
    return true if approval_roles.include?("sponsor") && sponsor == user
    return true if approval_roles.include?("manager") && manager == user
    return true if approval_roles.include?("responsible") && assignee == user
    false
  end

  def create_default_kanban_columns
    KanbanColumn::DEFAULT_COLUMNS.each_with_index do |col, index|
      kanban_columns.create!(
        label: col[:label],
        status: col[:status],
        position: index,
        color: col[:color]
      )
    end
  end

  def evm_metrics
    task_data = tasks.select(:estimated_hours, :progress, :status).to_a
    bac = task_data.sum { |t| t.estimated_hours.to_f }
    ev = task_data.sum { |t| t.estimated_hours.to_f * t.progress.to_f / 100.0 }

    done_tasks = task_data.count { |t| t.status == "done" }
    total_tasks = [task_data.size, 1].max

    actual_hours = TimeEntry.joins(:task).where(tasks: { project_id: id }).sum(:duration).to_f / 60.0

    pv = bac

    percent_complete = (done_tasks.to_f / total_tasks * 100).round(0)
    percent_ideal = 100
    idc = actual_hours > 0 ? (ev / actual_hours).round(2) : 0.0
    idp = pv > 0 ? (ev / pv).round(2) : 0.0
    task_rate = (done_tasks.to_f / total_tasks * 100).round(0)

    {
      percent_complete: percent_complete,
      percent_ideal: percent_ideal,
      idc: idc,
      idp: idp,
      task_rate: task_rate,
      bac: bac.round(2),
      ev: ev.round(2),
      ac: actual_hours.round(2),
      pv: pv.round(2)
    }
  end
end
