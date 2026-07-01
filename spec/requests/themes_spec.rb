require "rails_helper"

RSpec.describe "Themes", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "PATCH /theme" do
    it "updates the user theme" do
      patch theme_path, params: { theme: "dark" }
      expect(user.reload.theme).to eq("dark")
      expect(response).to redirect_to(root_path)
    end

    it "updates to light theme" do
      patch theme_path, params: { theme: "light" }
      expect(user.reload.theme).to eq("light")
      expect(response).to redirect_to(root_path)
    end

    it "updates to system theme" do
      user.update!(theme: "dark")
      patch theme_path, params: { theme: "system" }
      expect(user.reload.theme).to eq("system")
      expect(response).to redirect_to(root_path)
    end
  end
end
