require "rails_helper"

RSpec.describe "Programs", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:program) { create(:program, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/programs" do
    it "returns http success" do
      get organization_programs_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/programs/new" do
    it "returns http success" do
      get new_organization_program_path(organization)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/programs" do
    it "creates a new program" do
      expect {
        post organization_programs_path(organization), params: { program: { name: "New Program" } }
      }.to change(Program, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_programs_path(organization), params: { program: { name: "" } }
      }.not_to change(Program, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id/programs/:id" do
    it "returns http success" do
      get organization_program_path(organization, program)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/programs/:id/edit" do
    it "returns http success" do
      get edit_organization_program_path(organization, program)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /organizations/:id/programs/:id" do
    it "updates the program" do
      patch organization_program_path(organization, program), params: { program: { name: "Updated Program" } }
      expect(program.reload.name).to eq("Updated Program")
    end

    it "renders edit on failure" do
      patch organization_program_path(organization, program), params: { program: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /organizations/:id/programs/:id" do
    it "deletes the program" do
      program
      expect {
        delete organization_program_path(organization, program)
      }.to change(Program, :count).by(-1)
    end
  end

  describe "access control" do
    let(:viewer) { create(:user) }

    before do
      create(:organization_membership, user: viewer, organization: organization, role: :member)
    end

    it "allows members to view programs" do
      sign_in viewer
      get organization_programs_path(organization)
      expect(response).to have_http_status(:success)
    end

    it "allows members to view individual program" do
      sign_in viewer
      get organization_program_path(organization, program)
      expect(response).to have_http_status(:success)
    end

    it "denies non-members" do
      sign_out user
      other = create(:user)
      sign_in other
      get organization_programs_path(organization)
      expect(response).to have_http_status(:not_found)
    end
  end
end
