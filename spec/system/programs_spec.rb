require "rails_helper"

RSpec.describe "Programs", type: :system do
  let(:data) { create_user_with_organization }
  let(:user) { data[:user] }
  let(:organization) { data[:organization] }

  before do
    sign_in_as(user)
  end

  it "creates a program and shows it in the list" do
    visit organization_programs_path(organization)
    click_on "New Program"

    fill_in "Name", with: "Q4 Growth"
    fill_in "Description", with: "Growth initiatives for Q4"
    select "On Track", from: "Status"
    fill_in "Budget", with: "50000"

    click_on "Create Program"

    expect(page).to have_content("Program was successfully created")
    expect(page).to have_content("Q4 Growth")
  end

  it "edits a program" do
    program = create(:program, organization: organization, name: "Old Name")
    visit organization_program_path(organization, program)

    click_on "Edit"

    fill_in "Name", with: "Updated Name"
    click_on "Update Program"

    expect(page).to have_content("Program was successfully updated")
    expect(page).to have_content("Updated Name")
  end

  it "shows program details with rollup" do
    program = create(:program, organization: organization, name: "Rollup Test")
    project = create(:project, organization: organization, program: program, status: :on_track)
    create(:task, project: project, status: :done)

    visit organization_program_path(organization, program)

    expect(page).to have_content("Rollup Test")
    expect(page).to have_content(project.name)
  end

  it "shows program in sidebar navigation" do
    visit organization_programs_path(organization)
    expect(page).to have_link("Programs")
  end

  it "associates a project with a program from the project form" do
    create(:program, organization: organization, name: "My Program")

    visit new_organization_project_path(organization)
    fill_in "Name", with: "Project in Program"
    select "My Program", from: "Program"
    click_on "Create Project"

    expect(page).to have_content("Project was successfully created")
  end

  it "shows back link to program in project nav" do
    program = create(:program, organization: organization, name: "My Program")
    project = create(:project, organization: organization, program: program, name: "Child Project")

    visit organization_project_path(organization, project)

    expect(page).to have_content("My Program")
  end
end
