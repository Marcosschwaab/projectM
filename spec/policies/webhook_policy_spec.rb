require "rails_helper"

RSpec.describe WebhookPolicy do
  subject { described_class.new(user, webhook) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:webhook) { create(:webhook, organization: organization) }

  describe "permissions for members" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :member)
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for managers" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :manager)
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "permissions for admins" do
    before do
      create(:organization_membership, user: user, organization: organization, role: :admin)
    end

    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for non-members" do
    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end

  describe "scope" do
    it "returns webhooks accessible through memberships" do
      create(:organization_membership, user: user, organization: organization, role: :member)
      other_webhook = create(:webhook)
      scope = WebhookPolicy::Scope.new(user, Webhook).resolve
      expect(scope).to include(webhook)
      expect(scope).not_to include(other_webhook)
    end
  end
end
