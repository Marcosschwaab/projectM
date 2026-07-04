require "rails_helper"

RSpec.describe "Risks", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:risk) { create(:risk, project: project) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:organization_id/projects/:project_id/risks" do
    it "returns http success" do
      get organization_project_risks_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:organization_id/projects/:project_id/risks/new" do
    it "returns http success" do
      get new_organization_project_risk_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:organization_id/projects/:project_id/risks" do
    it "creates a new risk" do
      expect {
        post organization_project_risks_path(organization, project),
             params: { risk: { name: "New Risk", probability: 3, impact: 4 } }
      }.to change(Risk, :count).by(1)
      expect(response).to redirect_to(organization_project_risks_path(organization, project))
    end

    it "renders new on failure" do
      expect {
        post organization_project_risks_path(organization, project),
             params: { risk: { name: "", probability: 3, impact: 4 } }
      }.not_to change(Risk, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:organization_id/projects/:project_id/risks/:id/edit" do
    it "returns http success" do
      get edit_organization_project_risk_path(organization, project, risk)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:organization_id/projects/:project_id/risks/:id" do
    it "updates the risk" do
      patch organization_project_risk_path(organization, project, risk),
            params: { risk: { name: "Updated Risk" } }
      expect(risk.reload.name).to eq("Updated Risk")
      expect(response).to redirect_to(organization_project_risks_path(organization, project))
    end

    it "renders edit on failure" do
      patch organization_project_risk_path(organization, project, risk),
            params: { risk: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:organization_id/projects/:project_id/risks/:id" do
    it "deletes the risk" do
      risk
      expect {
        delete organization_project_risk_path(organization, project, risk)
      }.to change(Risk, :count).by(-1)
      expect(response).to redirect_to(organization_project_risks_path(organization, project))
    end
  end
end