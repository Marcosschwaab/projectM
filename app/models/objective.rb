class Objective < ApplicationRecord
  belongs_to :okr_cycle
  belongs_to :owner, class_name: "User", optional: true
  belongs_to :project, optional: true
  has_many :key_results, dependent: :destroy
  validates :title, presence: true

  scope :linked_to_project, -> { where.not(project_id: nil) }
  scope :unlinked, -> { where(project_id: nil) }

  def calculate_progress
    return 0 if key_results.empty?
    (key_results.map(&:calculate_progress).sum / key_results.size).round(1)
  end

  def update_progress!
    update!(progress: calculate_progress)
  end
end
