require "rails_helper"

RSpec.describe "KPIs", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:kpi) { create(:kpi, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/kpis" do
    it "returns http success" do
      get organization_kpis_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/kpis/new" do
    it "returns http success" do
      get new_organization_kpi_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/kpis" do
    it "creates a new kpi" do
      expect {
        post organization_kpis_path(organization), params: { kpi: { name: "New KPI", target_value: 100 } }
      }.to change(Kpi, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_kpis_path(organization), params: { kpi: { name: "", target_value: 100 } }
      }.not_to change(Kpi, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id/kpis/:id/edit" do
    it "returns http success" do
      get edit_organization_kpi_path(organization, kpi)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/kpis/:id" do
    it "updates the kpi" do
      patch organization_kpi_path(organization, kpi), params: { kpi: { name: "Updated KPI" } }
      expect(kpi.reload.name).to eq("Updated KPI")
    end

    it "updates current value and stores previous" do
      patch organization_kpi_path(organization, kpi), params: { kpi: { current_value: 50 } }
      expect(kpi.reload.current_value).to eq(50)
    end

    it "renders edit on failure" do
      patch organization_kpi_path(organization, kpi), params: { kpi: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/kpis/:id" do
    it "deletes the kpi" do
      kpi
      expect {
        delete organization_kpi_path(organization, kpi)
      }.to change(Kpi, :count).by(-1)
    end
  end
end
