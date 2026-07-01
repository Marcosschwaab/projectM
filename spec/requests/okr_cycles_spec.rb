require "rails_helper"

RSpec.describe "OKRCycles", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:cycle) { create(:okr_cycle, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/okr_cycles" do
    it "returns http success" do
      get organization_okr_cycles_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/okr_cycles/new" do
    it "returns http success" do
      get new_organization_okr_cycle_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/okr_cycles" do
    it "creates a new cycle" do
      expect {
        post organization_okr_cycles_path(organization), params: { okr_cycle: { title: "Q1 2025" } }
      }.to change(OkrCycle, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_okr_cycles_path(organization), params: { okr_cycle: { title: "" } }
      }.not_to change(OkrCycle, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id/okr_cycles/:id" do
    it "returns http success" do
      get organization_okr_cycle_path(organization, cycle)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/okr_cycles/:id/edit" do
    it "returns http success" do
      get edit_organization_okr_cycle_path(organization, cycle)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/okr_cycles/:id" do
    it "updates the cycle" do
      patch organization_okr_cycle_path(organization, cycle), params: { okr_cycle: { title: "Updated" } }
      expect(cycle.reload.title).to eq("Updated")
    end

    it "renders edit on failure" do
      patch organization_okr_cycle_path(organization, cycle), params: { okr_cycle: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/okr_cycles/:id" do
    it "deletes the cycle" do
      cycle
      expect {
        delete organization_okr_cycle_path(organization, cycle)
      }.to change(OkrCycle, :count).by(-1)
    end
  end
end
