require "rails_helper"

RSpec.describe RiskPolicy do
  subject { described_class.new(user, risk) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:risk) { create(:risk, project: project) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
    create(:project_member, user: user, project: project, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:index) }

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for managers" do
    let(:manager) { create(:user) }
    subject { described_class.new(manager, risk) }

    before do
      create(:organization_membership, user: manager, organization: organization, role: :manager)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for admins" do
    let(:admin) { create(:user) }
    subject { described_class.new(admin, risk) }

    before do
      create(:organization_membership, user: admin, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "scope" do
    it "returns risks in projects the user belongs to" do
      other_org = create(:organization)
      other_project = create(:project, organization: other_org)
      other_risk = create(:risk, project: other_project)
      scope = RiskPolicy::Scope.new(user, Risk).resolve
      expect(scope).to include(risk)
      expect(scope).not_to include(other_risk)
    end
  end
end