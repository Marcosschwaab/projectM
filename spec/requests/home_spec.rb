require "rails_helper"

RSpec.describe "Homes", type: :request do
  describe "GET /" do
    it "redirects to login when not authenticated" do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to dashboard when authenticated" do
      user = create(:user)
      sign_in user
      get root_path
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
