class ActivityLog < ApplicationRecord
  belongs_to :trackable, polymorphic: true
  belongs_to :user
  belongs_to :organization

  validates :action, presence: true
end
