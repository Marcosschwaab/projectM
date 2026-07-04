require "rails_helper"

RSpec.describe TaskPolicy do
  subject { described_class.new(user, task) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:task) { create(:task, project: project) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
    create(:project_member, user: user, project: project, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:modal) }
    it { is_expected.to permit_action(:move) }

    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for admins" do
    let(:admin) { create(:user) }
    subject { described_class.new(admin, task) }

    before do
      create(:organization_membership, user: admin, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for non-members" do
    let(:outsider) { create(:user) }
    subject { described_class.new(outsider, task) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "scope" do
    it "returns tasks accessible through memberships" do
      other_task = create(:task)
      scope = TaskPolicy::Scope.new(user, Task).resolve
      expect(scope).to include(task)
      expect(scope).not_to include(other_task)
    end
  end
end
