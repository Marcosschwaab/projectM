require "rails_helper"

RSpec.describe ObjectivePolicy do
  subject { described_class.new(user, objective) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:cycle) { create(:okr_cycle, organization: organization) }
  let(:objective) { create(:objective, okr_cycle: cycle) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:edit) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for admins" do
    let(:admin) { create(:user) }
    subject { described_class.new(admin, objective) }

    before do
      create(:organization_membership, user: admin, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:edit) }
    it { is_expected.to permit_action(:destroy) }
  end
end
