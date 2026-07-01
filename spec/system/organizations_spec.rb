require "rails_helper"

RSpec.describe "Organizations", type: :system do
  before { driven_by(:rack_test) }

  it "creates a new organization" do
    user = create(:user)

    sign_in_as(user)
    expect(page).to have_text("Create an organization to get started.")

    fill_in "Name", with: "My New Org"
    fill_in "Description", with: "A great organization"
    click_button "Create Organization"

    expect(page).to have_text("Organization was successfully created.")
    expect(page).to have_text("My New Org")
  end

  it "shows validation errors on create" do
    user = create(:user)

    sign_in_as(user)
    expect(page).to have_text("Create an organization to get started.")

    click_button "Create Organization"

    expect(page).to have_text(/error prohibited this organizations? from being saved/i)
  end

  it "edits an organization" do
    user, organization = create_user_with_organization.values_at(:user, :organization)

    sign_in_as(user)
    click_link "Organizations"
    click_link organization.name
    click_link "Edit"
    fill_in "Name", with: "Updated Org Name"
    click_button "Update Organization"

    expect(page).to have_text("Organization was successfully updated.")
    expect(page).to have_text("Updated Org Name")
  end

  it "views the organization page" do
    user = create(:user)
    organization = create(:organization, name: "Acme Corp")
    create(:organization_membership, user:, organization:, role: :admin)
    create(:project, organization:, name: "Project Alpha")

    sign_in_as(user)
    click_link "Organizations"
    click_link "Acme Corp"

    expect(page).to have_text("Acme Corp")
    expect(page).to have_text("Members")
    expect(page).to have_text("1")
  end
end
