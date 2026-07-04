require "rails_helper"

RSpec.describe StrategicCanvasPolicy do
  subject { described_class.new(user, canvas) }

  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:canvas) { create(:strategic_canvas, project: project) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
    create(:project_member, user: user, project: project, role: :member)
  end

  describe "permissions for members" do
    it { is_expected.to permit_action(:show) }
    it { is_expected.to permit_action(:update) }
  end

  describe "permissions for non-members" do
    let(:outsider) { create(:user) }
    subject { described_class.new(outsider, canvas) }

    it { is_expected.to forbid_action(:show) }
    it { is_expected.to forbid_action(:update) }
  end

  describe "scope" do
    it "returns canvases accessible through memberships" do
      other_canvas = create(:strategic_canvas)
      scope = StrategicCanvasPolicy::Scope.new(user, StrategicCanvas).resolve
      expect(scope).to include(canvas)
      expect(scope).not_to include(other_canvas)
    end
  end
end
