require "rails_helper"

RSpec.describe "Reports", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /report" do
    it "returns http success" do
      get report_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /report.pdf" do
    it "returns a PDF file" do
      create(:project, organization: organization, name: "Test Project")
      get report_path(format: :pdf)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("report.pdf")
    end
  end
end
