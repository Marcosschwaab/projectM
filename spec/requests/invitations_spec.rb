require "rails_helper"

RSpec.describe "Invitations", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/invitations" do
    it "returns http success" do
      get organization_invitations_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/invitations/new" do
    it "returns http success" do
      get new_organization_invitation_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/invitations" do
    it "creates a new invitation" do
      expect {
        post organization_invitations_path(organization), params: { invitation: { email: "new@test.com" } }
      }.to change(Invitation, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_invitations_path(organization), params: { invitation: { email: "" } }
      }.not_to change(Invitation, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
