require "rails_helper"

RSpec.describe "KeyResults", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:cycle) { create(:okr_cycle, organization: organization) }
  let(:objective) { create(:objective, okr_cycle: cycle) }
  let(:key_result) { create(:key_result, objective: objective) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "POST /organizations/:id/okr_cycles/:id/objectives/:id/key_results" do
    it "creates a new key result" do
      expect {
        post organization_okr_cycle_objective_key_results_path(organization, cycle, objective), params: { key_result: { title: "New KR", target_value: 100 } }
      }.to change(KeyResult, :count).by(1)
    end

    it "redirects on failure" do
      expect {
        post organization_okr_cycle_objective_key_results_path(organization, cycle, objective), params: { key_result: { title: "" } }
      }.not_to change(KeyResult, :count)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "GET /organizations/:id/okr_cycles/:id/objectives/:id/key_results/:id/edit" do
    it "returns http success" do
      get edit_organization_okr_cycle_objective_key_result_path(organization, cycle, objective, key_result)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/okr_cycles/:id/objectives/:id/key_results/:id" do
    it "updates the key result" do
      patch organization_okr_cycle_objective_key_result_path(organization, cycle, objective, key_result), params: { key_result: { current_value: 50 } }
      expect(key_result.reload.current_value).to eq(50)
    end

    it "renders edit on failure" do
      patch organization_okr_cycle_objective_key_result_path(organization, cycle, objective, key_result), params: { key_result: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/okr_cycles/:id/objectives/:id/key_results/:id" do
    it "deletes the key result" do
      key_result
      expect {
        delete organization_okr_cycle_objective_key_result_path(organization, cycle, objective, key_result)
      }.to change(KeyResult, :count).by(-1)
    end
  end
end
