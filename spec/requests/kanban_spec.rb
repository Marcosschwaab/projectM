require "rails_helper"

RSpec.describe "Kanban", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/projects/:id/kanban" do
    it "returns http success" do
      get organization_project_kanban_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end
end
