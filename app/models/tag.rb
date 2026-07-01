class Tag < ApplicationRecord
  belongs_to :organization
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  validates :name, presence: true
  validates :name, uniqueness: { scope: :organization }
end
