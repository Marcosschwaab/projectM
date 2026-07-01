class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :invitations, dependent: :nullify
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :dashboard_widgets, dependent: :destroy

  def member_of?(organization)
    organization_memberships.exists?(organization: organization)
  end

  def role_in(organization)
    organization_memberships.find_by(organization: organization)&.role
  end
end
