class ActivityLog < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :user
  belongs_to :organization
  belongs_to :project, optional: true

  validates :action, presence: true

  scope :for_project, ->(project) { where(project: project) }
  scope :recent, -> { order(created_at: :desc) }
end
