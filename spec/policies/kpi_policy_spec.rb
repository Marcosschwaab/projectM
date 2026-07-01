require "rails_helper"

RSpec.describe KpiPolicy do
  subject { described_class.new(user, kpi) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:kpi) { create(:kpi, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:index) }

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:new) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for managers" do
    let(:manager) { create(:user) }
    subject { described_class.new(manager, kpi) }

    before do
      create(:organization_membership, user: manager, organization: organization, role: :manager)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for admins" do
    let(:admin) { create(:user) }
    subject { described_class.new(admin, kpi) }

    before do
      create(:organization_membership, user: admin, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "scope" do
    it "returns KPIs in organizations the user belongs to" do
      other_org = create(:organization)
      other_kpi = create(:kpi, organization: other_org)
      scope = KpiPolicy::Scope.new(user, Kpi).resolve
      expect(scope).to include(kpi)
      expect(scope).not_to include(other_kpi)
    end
  end
end
