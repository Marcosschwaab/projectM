class Kpi < ApplicationRecord
  belongs_to :organization
  belongs_to :project, optional: true
  belongs_to :owner, class_name: "User", optional: true

  validates :name, presence: true

  enum :category, { strategic: 0, project: 1, quality: 2, operational: 3, financial: 4 }
  enum :frequency, { daily: 0, weekly: 1, monthly: 2, quarterly: 3, yearly: 4 }
  enum :trend, { flat: 0, up: 1, down: 2 }

  scope :org_wide, -> { where(project_id: nil) }
  scope :by_project, ->(project) { where(project: project) }
  scope :active, -> { where(Project.arel_table[:archived_at].eq(nil).or(arel_table[:project_id].eq(nil))) }

  def calculate_progress
    return 0 if target_value.blank? || target_value.zero?
    ((current_value.to_f / target_value.to_f) * 100).round(1)
  end

  def status
    progress = calculate_progress
    if progress >= 100 then "achieved"
    elsif progress >= 75 then "on_track"
    elsif progress >= 50 then "at_risk"
    elsif progress >= 25 then "behind"
    else "critical"
    end
  end

  def self.calculate_trend(current:, previous:)
    return "flat" if previous.nil? || previous.zero?
    return "up" if current > previous
    return "down" if current < previous
    "flat"
  end
end
