require "rails_helper"

RSpec.describe "CustomFields", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/custom_fields" do
    it "returns http success" do
      get organization_custom_fields_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/custom_fields/new" do
    it "returns http success" do
      get new_organization_custom_field_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/custom_fields" do
    it "creates a custom field" do
      expect {
        post organization_custom_fields_path(organization), params: {
          custom_field: { name: "Priority Score", field_type: "number" }
        }
      }.to change(CustomField, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_custom_fields_path(organization), params: {
          custom_field: { name: "", field_type: "" }
        }
      }.not_to change(CustomField, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /organizations/:id/custom_fields/:id" do
    it "updates a custom field" do
      field = create(:custom_field, organization: organization, name: "Old")
      patch organization_custom_field_path(organization, field), params: {
        custom_field: { name: "Updated" }
      }
      expect(field.reload.name).to eq("Updated")
    end
  end

  describe "DELETE /organizations/:id/custom_fields/:id" do
    it "deletes a custom field" do
      field = create(:custom_field, organization: organization)
      expect {
        delete organization_custom_field_path(organization, field)
      }.to change(CustomField, :count).by(-1)
    end
  end
end
