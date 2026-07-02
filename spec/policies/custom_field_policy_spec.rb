require "rails_helper"

RSpec.describe CustomFieldPolicy do
  subject { described_class.new(user, custom_field) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:custom_field) { build(:custom_field, organization: organization) }

  describe "permissions for admin" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for manager" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :manager)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for member" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :member)
    end

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
