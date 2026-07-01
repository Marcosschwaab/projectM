require "rails_helper"

RSpec.describe "Calendar", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/calendar" do
    it "returns http success" do
      get organization_calendar_path(organization)
      expect(response).to have_http_status(:success)
    end
  end
end
