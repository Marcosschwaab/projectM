require "rails_helper"

RSpec.describe "Projects", type: :system do
  before { driven_by(:rack_test) }

  it "creates a project" do
    user, organization = create_user_with_organization.values_at(:user, :organization)

    sign_in_as(user)
    click_link "Projects"
    click_link "New Project"
    fill_in "Name", with: "My New Project"
    fill_in "Description", with: "A great project"
    click_button "Create Project"

    expect(page).to have_text("Project was successfully created.")
    expect(page).to have_text("My New Project")
  end

  it "shows validation errors on create" do
    user, organization = create_user_with_organization.values_at(:user, :organization)

    sign_in_as(user)
    click_link "Projects"
    click_link "New Project"
    click_button "Create Project"

    expect(page).to have_text(/error prohibited this projects? from being saved/i)
  end

  it "edits a project" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, name: "Old Name")

    sign_in_as(user)
    click_link "Projects"
    click_link "Old Name"
    click_link "Edit"
    fill_in "Name", with: "Updated Project Name"
    click_button "Update Project"

    expect(page).to have_text("Project was successfully updated.")
    expect(page).to have_text("Updated Project Name")
  end

  it "lists projects in the organization" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    create(:project, organization:, name: "Alpha")
    create(:project, organization:, name: "Beta")

    sign_in_as(user)
    click_link "Projects"

    expect(page).to have_text("Alpha")
    expect(page).to have_text("Beta")
  end
end
