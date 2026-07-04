class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true

  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, through: :organization_memberships
  has_many :project_members, dependent: :destroy
  has_many :invitations, dependent: :nullify
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :dashboard_widgets, dependent: :destroy
  has_many :time_entries, dependent: :destroy

  def member_of?(organization)
    organization_memberships.exists?(organization: organization)
  end

  def role_in(organization)
    organization_memberships.find_by(organization: organization)&.role
  end

  def org_role(organization)
    role_in(organization)
  end

  def super_admin?(organization)
    org_role(organization) == "super_admin"
  end

  def org_admin?(organization)
    org_role(organization) == "admin"
  end

  def org_admin_or_manager?(organization)
    %w[admin manager].include?(org_role(organization))
  end

  def project_role_for(project)
    project_members.find_by(project: project)&.role
  end

  def project_manager?(project)
    project_role_for(project) == "manager"
  end

  def project_member?(project)
    project_role_for(project) == "member"
  end

  def can_access_project?(project)
    super_admin?(project.organization) ||
      org_admin_or_manager?(project.organization) ||
      project_members.exists?(project: project) ||
      project_members.joins(:project).where(projects: { organization_id: project.organization_id }, role: :manager).exists?
  end
end
