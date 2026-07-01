class Project < ApplicationRecord
  belongs_to :organization
  belongs_to :assignee, class_name: "User", optional: true

  has_many :tasks, dependent: :destroy
  has_one :strategic_canvas, dependent: :destroy
  has_many :objectives, dependent: :nullify
  has_many :kpis, dependent: :destroy

  validates :name, presence: true
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }
  enum :status, { on_track: 0, at_risk: 1, behind: 2, on_hold: 3, completed: 4 }

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }
end
