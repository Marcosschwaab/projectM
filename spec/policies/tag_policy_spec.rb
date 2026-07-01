require "rails_helper"

RSpec.describe TagPolicy do
  subject { described_class.new(user, tag) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:tag) { create(:tag, organization: organization) }

  describe "permissions for members" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :member)
    end

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for managers" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :manager)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for admins" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for non-members" do
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "scope" do
    it "returns tags accessible through memberships" do
      create(:organization_membership, user: user, organization: organization, role: :member)
      other_tag = create(:tag)
      scope = TagPolicy::Scope.new(user, Tag).resolve
      expect(scope).to include(tag)
      expect(scope).not_to include(other_tag)
    end
  end
end
