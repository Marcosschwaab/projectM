class Program < ApplicationRecord
  STATUSES = %w[on_track at_risk behind on_hold completed].freeze

  belongs_to :organization
  has_many :projects, dependent: :nullify
  has_many :objectives, through: :projects
  has_many :kpis, through: :projects
  has_many :risks, through: :projects
  has_many :project_members, through: :projects

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "must be a valid hex color" }, allow_blank: true
  validates :status, inclusion: { in: STATUSES }, allow_blank: true

  enum :status, { on_track: "on_track", at_risk: "at_risk", behind: "behind", on_hold: "on_hold", completed: "completed" }, prefix: true

  def progress
    active_projects = projects.active
    return 0 if active_projects.empty?
    (active_projects.sum(&:progress).to_f / active_projects.size).round(0)
  end

  def total_budget_estimated
    projects.sum(:budget_estimated)
  end

  def total_budget_actual
    projects.sum(:budget_actual)
  end

  def tasks_count
    projects.joins(:tasks).count
  end

  def tasks_done_count
    projects.joins(:tasks).where(tasks: { status: :done }).count
  end

  def objectives_count
    objectives.count
  end

  def key_results_count
    KeyResult.joins(:objective).where(objectives: { project_id: projects.select(:id) }).count
  end

  def risks_count
    risks.count
  end

  def risks_open_count
    risks.open.count
  end
end
