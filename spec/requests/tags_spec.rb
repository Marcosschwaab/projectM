require "rails_helper"

RSpec.describe "Tags", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/tags" do
    it "returns http success" do
      get organization_tags_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/tags/new" do
    it "returns http success" do
      get new_organization_tag_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/tags" do
    it "creates a new tag" do
      expect {
        post organization_tags_path(organization), params: { tag: { name: "Bug", color: "#ef4444" } }
      }.to change(Tag, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_tags_path(organization), params: { tag: { name: "" } }
      }.not_to change(Tag, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id/tags/:id/edit" do
    it "returns http success" do
      tag = create(:tag, organization: organization)
      get edit_organization_tag_path(organization, tag)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/tags/:id" do
    it "updates the tag" do
      tag = create(:tag, organization: organization, name: "Bug")
      patch organization_tag_path(organization, tag), params: { tag: { name: "Feature" } }
      expect(tag.reload.name).to eq("Feature")
    end

    it "renders edit on failure" do
      tag = create(:tag, organization: organization, name: "Bug")
      patch organization_tag_path(organization, tag), params: { tag: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/tags/:id" do
    it "deletes the tag" do
      tag = create(:tag, organization: organization)
      expect {
        delete organization_tag_path(organization, tag)
      }.to change(Tag, :count).by(-1)
    end
  end

  describe "authorization" do
    it "redirects when not authenticated" do
      sign_out user
      get organization_tags_path(organization)
      expect(response).to have_http_status(:redirect)
    end
  end
end
