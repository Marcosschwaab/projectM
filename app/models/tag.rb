class Tag < ApplicationRecord
  belongs_to :organization
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization }
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "must be a valid hex color" }
end
