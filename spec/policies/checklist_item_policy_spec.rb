require "rails_helper"

RSpec.describe ChecklistItemPolicy do
  subject { described_class.new(user, item) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:task) { create(:task, project: project) }
  let(:item) { build(:checklist_item, task: task) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for non-members" do
    let(:outsider) { create(:user) }
    subject { described_class.new(outsider, item) }

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
