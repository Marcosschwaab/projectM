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
  end

  describe "GET /organizations/:id" do
    it "returns http success" do
      get organization_path(organization)
      expect(response).to have_http_status(:success)
    end
  end
end
