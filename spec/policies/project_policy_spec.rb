require "rails_helper"

RSpec.describe ProjectPolicy do
  subject { described_class.new(user, project) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }

    it { is_expected.to forbid_action(:destroy) }
    it { is_expected.to forbid_action(:archive) }
  end

  describe "permissions for admins" do
    let(:admin) { create(:user) }
    subject { described_class.new(admin, project) }

    before do
      create(:organization_membership, user: admin, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:archive) }
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
    it "returns projects in organizations the user belongs to" do
      other_org = create(:organization)
      other_project = create(:project, organization: other_org)
      scope = ProjectPolicy::Scope.new(user, Project).resolve
      expect(scope).to include(project)
      expect(scope).not_to include(other_project)
    end
  end
end
