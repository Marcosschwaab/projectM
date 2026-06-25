class OrganizationMembership < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, { member: 0, manager: 1, admin: 2 }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :organization_id, message: "is already a member" }
end
