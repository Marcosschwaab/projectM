class Organization < ApplicationRecord
  has_many :custom_fields, dependent: :destroy
  has_many :memberships, class_name: "OrganizationMembership", dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :invitations, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :okr_cycles, dependent: :destroy
  has_many :objectives, through: :okr_cycles
  has_many :kpis, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :webhooks, dependent: :destroy

  validates :name, presence: true
end
