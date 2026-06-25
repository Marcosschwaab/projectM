require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/projects" do
    it "returns http success" do
      get organization_projects_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/projects" do
    it "creates a new project" do
      expect {
        post organization_projects_path(organization), params: { project: { name: "Test Project" } }
      }.to change(Project, :count).by(1)
    end
  end
end
