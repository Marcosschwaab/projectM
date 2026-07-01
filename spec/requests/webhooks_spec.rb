require "rails_helper"

RSpec.describe "Webhooks", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/webhooks" do
    it "returns http success" do
      get organization_webhooks_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/webhooks/new" do
    it "returns http success" do
      get new_organization_webhook_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/webhooks" do
    it "creates a new webhook" do
      expect {
        post organization_webhooks_path(organization), params: {
          webhook: { name: "My Hook", url: "https://example.com/hook", events: [ "task.created" ] }
        }
      }.to change(Webhook, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_webhooks_path(organization), params: {
          webhook: { name: "", url: "" }
        }
      }.not_to change(Webhook, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id/webhooks/:id" do
    it "returns http success" do
      webhook = create(:webhook, organization: organization)
      get organization_webhook_path(organization, webhook)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/webhooks/:id/edit" do
    it "returns http success" do
      webhook = create(:webhook, organization: organization)
      get edit_organization_webhook_path(organization, webhook)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/webhooks/:id" do
    it "updates the webhook" do
      webhook = create(:webhook, organization: organization, name: "Old Name")
      patch organization_webhook_path(organization, webhook), params: {
        webhook: { name: "New Name" }
      }
      expect(webhook.reload.name).to eq("New Name")
    end

    it "renders edit on failure" do
      webhook = create(:webhook, organization: organization)
      patch organization_webhook_path(organization, webhook), params: {
        webhook: { name: "" }
      }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/webhooks/:id" do
    it "deletes the webhook" do
      webhook = create(:webhook, organization: organization)
      expect {
        delete organization_webhook_path(organization, webhook)
      }.to change(Webhook, :count).by(-1)
    end
  end
end
