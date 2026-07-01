require "rails_helper"

RSpec.describe "StrategicCanvases", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:canvas) { create(:strategic_canvas, project: project) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/projects/:id/strategic_canvas" do
    it "returns http success with existing canvas" do
      canvas
      get organization_project_strategic_canvas_path(organization, project)
      expect(response).to have_http_status(:success)
    end

    it "returns http success without existing canvas" do
      get organization_project_strategic_canvas_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/projects/:id/strategic_canvas" do
    it "updates the canvas" do
      patch organization_project_strategic_canvas_path(organization, project), params: { strategic_canvas: { goal: "New goal" } }
      canvas = project.reload.strategic_canvas
      expect(canvas.goal).to eq("New goal")
    end

    it "renders show on failure" do
      patch organization_project_strategic_canvas_path(organization, project), params: { strategic_canvas: { goal: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
