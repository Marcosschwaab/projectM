require "rails_helper"

RSpec.describe TimeEntryPolicy do
  subject { described_class.new(user, time_entry) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:task) { create(:task, project: project) }
  let(:time_entry) { build(:time_entry, task: task) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
    create(:project_member, user: user, project: project, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:start) }
    it { is_expected.to permit_action(:stop) }
    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
  end

  describe "permissions for non-members" do
    let(:outsider) { create(:user) }
    subject { described_class.new(outsider, time_entry) }

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:start) }
    it { is_expected.to forbid_action(:stop) }
    it { is_expected.to forbid_action(:update) }
    it { is_expected.to forbid_action(:destroy) }
  end
end
