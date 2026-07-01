require "rails_helper"

RSpec.describe OrganizationPolicy do
  subject { described_class.new(user, organization) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
  end

  describe "permissions" do
    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }

    it "denies update for members" do
      is_expected.to forbid_action(:update)
    end

    it "denies destroy for members" do
      is_expected.to forbid_action(:destroy)
    end

    context "when admin" do
      let(:admin) { create(:user) }
      subject { described_class.new(admin, organization) }

      before do
        create(:organization_membership, user: admin, organization: organization, role: :admin)
      end

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
      it { is_expected.to permit_action(:manage_members) }
    end
  end

  describe "scope" do
    it "returns organizations the user belongs to" do
      other_org = create(:organization)
      scope = OrganizationPolicy::Scope.new(user, Organization).resolve
      expect(scope).to include(organization)
      expect(scope).not_to include(other_org)
    end
  end
end
