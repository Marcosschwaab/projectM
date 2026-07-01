require "rails_helper"

RSpec.describe "Tasks", type: :system do
  before { driven_by(:rack_test) }

  it "creates a task" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, assignee: user, name: "Test Project")

    sign_in_as(user)
    visit new_organization_project_task_path(organization, project)
    fill_in "Title", with: "My New Task"
    click_button "Create Task"

    expect(page).to have_text("Task was successfully created.")
    expect(page).to have_text("My New Task")
  end

  it "shows validation errors on create" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, name: "Test Project")

    sign_in_as(user)
    visit new_organization_project_task_path(organization, project)
    click_button "Create Task"

    expect(page).to have_text(/error prohibited this tasks? from being saved/i)
  end

  it "edits a task" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, assignee: user, name: "Test Project")
    task = create(:task, project:, title: "Old Task Title")

    sign_in_as(user)
    visit edit_organization_project_task_path(organization, project, task)
    fill_in "Title", with: "Updated Task Title"
    click_button "Update Task"

    expect(page).to have_text("Task was successfully updated.")
    expect(page).to have_text("Updated Task Title")
  end

  it "displays tasks on project page" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, assignee: user, name: "Test Project")
    create(:task, project:, title: "Homepage redesign", status: :done)
    create(:task, project:, title: "Fix login bug", status: :in_progress)

    sign_in_as(user)
    visit organization_project_path(organization, project)

    expect(page).to have_text("Homepage redesign")
    expect(page).to have_text("Fix login bug")
  end

  it "shows a task detail page" do
    user, organization = create_user_with_organization.values_at(:user, :organization)
    project = create(:project, organization:, assignee: user, name: "Test Project")
    task = create(:task, project:, title: "Task Detail View", assignee: user)

    sign_in_as(user)
    visit organization_project_task_path(organization, project, task)

    expect(page).to have_text("Task Detail View")
  end
end
