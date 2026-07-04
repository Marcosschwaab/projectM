require "rails_helper"

RSpec.describe ProgramPolicy do
  subject { described_class.new(user, program) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:program) { create(:program, organization: organization) }

  describe "permissions for non-members" do
    it { is_expected.to forbid_action(:index) }
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user is an org member" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :member)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }

    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user is an org manager" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :manager)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }

    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user is an org admin" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when user is a super_admin" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :super_admin)
    end

    it { is_expected.to permit_action(:index) }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "Scope" do
    it "returns programs for organization members" do
      create(:organization_membership, user: user, organization: organization, role: :member)
      scope = described_class::Scope.new(user, Program.all)
      expect(scope.resolve).to include(program)
    end

    it "does not return programs for non-members" do
      scope = described_class::Scope.new(user, Program.all)
      expect(scope.resolve).not_to include(program)
    end
  end
end
