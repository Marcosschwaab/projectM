require "rails_helper"

RSpec.describe "Objectives", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:cycle) { create(:okr_cycle, organization: organization) }
  let(:objective) { create(:objective, okr_cycle: cycle) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "POST /organizations/:id/okr_cycles/:id/objectives" do
    it "creates a new objective" do
      expect {
        post organization_okr_cycle_objectives_path(organization, cycle), params: { objective: { title: "New objective" } }
      }.to change(Objective, :count).by(1)
    end

    it "redirects on failure" do
      expect {
        post organization_okr_cycle_objectives_path(organization, cycle), params: { objective: { title: "" } }
      }.not_to change(Objective, :count)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /organizations/:id/okr_cycles/:id/objectives/:id/edit" do
    it "returns http success" do
      get edit_organization_okr_cycle_objective_path(organization, cycle, objective)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/okr_cycles/:id/objectives/:id" do
    it "updates the objective" do
      patch organization_okr_cycle_objective_path(organization, cycle, objective), params: { objective: { title: "Updated" } }
      expect(objective.reload.title).to eq("Updated")
    end

    it "renders edit on failure" do
      patch organization_okr_cycle_objective_path(organization, cycle, objective), params: { objective: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/okr_cycles/:id/objectives/:id" do
    it "deletes the objective" do
      objective
      expect {
        delete organization_okr_cycle_objective_path(organization, cycle, objective)
      }.to change(Objective, :count).by(-1)
    end
  end
end
