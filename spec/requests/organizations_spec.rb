require "rails_helper"

RSpec.describe "Organizations", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations" do
    it "returns http success" do
      get organizations_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/new" do
    it "returns http success" do
      get new_organization_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations" do
    it "creates a new organization" do
      expect {
        post organizations_path, params: { organization: { name: "Test Org" } }
      }.to change(Organization, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organizations_path, params: { organization: { name: "" } }
      }.not_to change(Organization, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id" do
    it "returns http success" do
      get organization_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id" do
    it "updates the organization" do
      patch organization_path(organization), params: { organization: { name: "Updated" } }
      expect(organization.reload.name).to eq("Updated")
    end

    it "renders edit on failure" do
      patch organization_path(organization), params: { organization: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id" do
    it "deletes the organization" do
      expect {
        delete organization_path(organization)
      }.to change(Organization, :count).by(-1)
    end
  end

  describe "authorization" do
    it "redirects when not authorized" do
      other_org = create(:organization)
      get organization_path(other_org)
      expect(response).to have_http_status(:redirect)
    end
  end
end
