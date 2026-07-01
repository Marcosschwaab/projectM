require "rails_helper"

RSpec.describe CommentPolicy do
  subject { described_class.new(user, comment) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:task) { create(:task, project: project) }
  let(:comment) { build(:comment, task: task) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:create) }
  end

  describe "permissions for non-members" do
    let(:outsider) { create(:user) }
    subject { described_class.new(outsider, comment) }

    it { is_expected.to forbid_action(:create) }
  end
end
