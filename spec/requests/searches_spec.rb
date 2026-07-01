require "rails_helper"

RSpec.describe "Searches", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /search" do
    it "returns http success with query" do
      get search_path(q: "test")
      expect(response).to have_http_status(:success)
    end

    it "returns http success without query" do
      get search_path
      expect(response).to have_http_status(:success)
    end
  end
end
