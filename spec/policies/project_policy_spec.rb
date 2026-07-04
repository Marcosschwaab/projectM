require "rails_helper"

RSpec.describe ProjectPolicy do
  subject { described_class.new(user, project) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:other_project) { create(:project, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
  end

  describe "permissions for org members (no project membership)" do
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:create) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:archive) }
  end

  describe "permissions for project members" do
    before do
      create(:project_member, user: user, project: project, role: :member)
    end

    it { is_expected.to permit_action(:show) }

    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:archive) }
  end

  describe "permissions for project managers" do
    before do
      create(:project_member, user: user, project: project, role: :manager)
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:manage_members) }

    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:archive) }
  end

  describe "permissions for org admins" do
    let(:admin) { create(:user) }
    subject { described_class.new(admin, project) }

    before do
      create(:organization_membership, user: admin, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to permit_action(:manage_members) }
  end

  describe "permissions for org managers" do
    let(:manager_user) { create(:user) }
    subject { described_class.new(manager_user, project) }

    before do
      create(:organization_membership, user: manager_user, organization: organization, role: :manager)
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to permit_action(:manage_members) }

    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for super admins" do
    let(:super_admin) { create(:user) }
    subject { described_class.new(super_admin, project) }

    before do
      create(:organization_membership, user: super_admin, organization: organization, role: :super_admin)
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
    it { is_expected.to permit_action(:manage_members) }
  end

  describe "permissions for non-members" do
    let(:outsider) { create(:user) }
    subject { described_class.new(outsider, project) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "scope" do
    let(:other_org) { create(:organization) }
    let(:other_project) { create(:project, organization: other_org) }

    it "returns only assigned projects for org members without project membership" do
      scope = ProjectPolicy::Scope.new(user, Project).resolve
      expect(scope).not_to include(project)
      expect(scope).not_to include(other_project)
    end

    it "returns all org projects for project managers" do
      create(:project_member, user: user, project: project, role: :manager)
      another_project = create(:project, organization: organization)
      scope = ProjectPolicy::Scope.new(user, Project).resolve
      expect(scope).to include(project)
      expect(scope).to include(another_project)
      expect(scope).not_to include(other_project)
    end

    it "returns all org projects for org admins" do
      admin = create(:user)
      create(:organization_membership, user: admin, organization: organization, role: :admin)
      scope = ProjectPolicy::Scope.new(admin, Project).resolve
      expect(scope).to include(project)
      expect(scope).not_to include(other_project)
    end
  end
end
