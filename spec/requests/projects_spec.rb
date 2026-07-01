require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }

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

  describe "GET /organizations/:id/projects/new" do
    it "returns http success" do
      get new_organization_project_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/projects" do
    it "creates a new project" do
      expect {
        post organization_projects_path(organization), params: { project: { name: "Test Project" } }
      }.to change(Project, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_projects_path(organization), params: { project: { name: "" } }
      }.not_to change(Project, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id/projects/:id" do
    it "returns http success" do
      get organization_project_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/projects/:id/edit" do
    it "returns http success" do
      get edit_organization_project_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/projects/:id" do
    it "updates the project" do
      patch organization_project_path(organization, project), params: { project: { name: "Updated" } }
      expect(project.reload.name).to eq("Updated")
    end

    it "renders edit on failure" do
      patch organization_project_path(organization, project), params: { project: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/projects/:id" do
    it "deletes the project" do
      project
      expect {
        delete organization_project_path(organization, project)
      }.to change(Project, :count).by(-1)
    end
  end

  describe "PATCH /organizations/:id/projects/:id/archive" do
    it "toggles archive status" do
      patch archive_organization_project_path(organization, project)
      expect(project.reload.archived).to be true
    end
  end
end
