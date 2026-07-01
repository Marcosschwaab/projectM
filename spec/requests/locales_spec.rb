require "rails_helper"

RSpec.describe "Locales", type: :request do
  let(:user) { create(:user) }

  describe "GET /locale/:locale" do
    it "switches locale for signed-in user" do
      sign_in user
      get switch_locale_path(:en)
      expect(response).to have_http_status(:redirect)
    end

    it "switches locale for guest" do
      get switch_locale_path(:en)
      expect(response).to have_http_status(:redirect)
    end

    it "rejects invalid locale" do
      get switch_locale_path(:invalid)
      expect(response).to have_http_status(:redirect)
    end
  end
end
