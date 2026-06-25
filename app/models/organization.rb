class Organization < ApplicationRecord
  has_many :memberships, class_name: "OrganizationMembership", dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :invitations, dependent: :destroy

  validates :name, presence: true
end
