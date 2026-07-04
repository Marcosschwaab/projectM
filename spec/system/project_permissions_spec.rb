require "rails_helper"

RSpec.describe "Project Permissions", type: :system do
  before { driven_by(:rack_test) }

  let(:organization) { create(:organization) }
  let(:project_alpha) { create(:project, organization:, name: "Alpha") }
  let(:project_beta) { create(:project, organization:, name: "Beta") }
  let(:task_in_alpha) { create(:task, project: project_alpha, title: "Alpha Task") }
  let(:task_in_beta) { create(:task, project: project_beta, title: "Beta Task") }

  shared_context "with projects and tasks" do
    before do
      project_alpha
      project_beta
      task_in_alpha
      task_in_beta
    end
  end

  context "as super admin" do
    let(:user) { create(:user) }

    before do
      create(:organization_membership, user:, organization:, role: :super_admin)
      sign_in_as(user)
    end

    include_context "with projects and tasks"

    it "sees all projects" do
      visit organization_projects_path(organization)
      expect(page).to have_text("Alpha")
      expect(page).to have_text("Beta")
    end

    it "accesses any project show page" do
      visit organization_project_path(organization, project_alpha)
      expect(page).to have_text("Alpha")
    end

    it "accesses any project edit page" do
      visit edit_organization_project_path(organization, project_alpha)
      expect(page).to have_text("Edit")
    end

    it "sees tasks in any project" do
      visit organization_project_tasks_path(organization, project_alpha)
      expect(page).to have_text("Alpha Task")

      visit organization_project_tasks_path(organization, project_beta)
      expect(page).to have_text("Beta Task")
    end

    it "creates a task" do
      visit new_organization_project_task_path(organization, project_alpha)
      fill_in "Title", with: "New Super Task"
      click_button "Create Task"
      expect(page).to have_text("Task was successfully created")
    end

    it "deletes a task" do
      expect {
        page.driver.submit(:delete, organization_project_task_path(organization, project_alpha, task_in_alpha), {})
      }.to change(Task, :count).by(-1)
    end
  end

  context "as org admin" do
    let(:user) { create(:user) }

    before do
      create(:organization_membership, user:, organization:, role: :admin)
      sign_in_as(user)
    end

    include_context "with projects and tasks"

    it "sees all projects" do
      visit organization_projects_path(organization)
      expect(page).to have_text("Alpha")
      expect(page).to have_text("Beta")
    end

    it "accesses any project edit page" do
      visit edit_organization_project_path(organization, project_alpha)
      expect(page).to have_text("Edit")
    end

    it "sees tasks in any project" do
      visit organization_project_tasks_path(organization, project_beta)
      expect(page).to have_text("Beta Task")
    end

    it "creates a task" do
      visit new_organization_project_task_path(organization, project_beta)
      fill_in "Title", with: "Admin Task"
      click_button "Create Task"
      expect(page).to have_text("Task was successfully created")
    end

    it "deletes a task" do
      expect {
        page.driver.submit(:delete, organization_project_task_path(organization, project_beta, task_in_beta), {})
      }.to change(Task, :count).by(-1)
    end
  end

  context "as org manager" do
    let(:user) { create(:user) }

    before do
      create(:organization_membership, user:, organization:, role: :manager)
      sign_in_as(user)
    end

    include_context "with projects and tasks"

    it "sees all projects" do
      visit organization_projects_path(organization)
      expect(page).to have_text("Alpha")
      expect(page).to have_text("Beta")
    end

    it "sees tasks in any project" do
      visit organization_project_tasks_path(organization, project_alpha)
      expect(page).to have_text("Alpha Task")
    end

    it "deletes a task" do
      expect {
        page.driver.submit(:delete, organization_project_task_path(organization, project_alpha, task_in_alpha), {})
      }.to change(Task, :count).by(-1)
    end
  end

  context "as project manager" do
    let(:user) { create(:user) }

    before do
      create(:organization_membership, user:, organization:, role: :member)
      create(:project_member, user:, project: project_alpha, role: :manager)
      sign_in_as(user)
    end

    include_context "with projects and tasks"

    it "sees all projects in the list" do
      visit organization_projects_path(organization)
      expect(page).to have_text("Alpha")
      expect(page).to have_text("Beta")
    end

    it "accesses any project show page" do
      visit organization_project_path(organization, project_beta)
      expect(page).to have_text("Beta")
    end

    it "edits their managed project" do
      visit edit_organization_project_path(organization, project_alpha)
      expect(page).to have_text("Edit")
    end

    it "cannot edit a non-managed project" do
      visit edit_organization_project_path(organization, project_beta)
      expect(page).to have_text(/not authorized/i)
    end

    it "sees tasks in their managed project" do
      visit organization_project_tasks_path(organization, project_alpha)
      expect(page).to have_text("Alpha Task")
    end

    it "sees tasks in other projects" do
      visit organization_project_tasks_path(organization, project_beta)
      expect(page).to have_text("Beta Task")
    end

    it "creates a task in their managed project" do
      visit new_organization_project_task_path(organization, project_alpha)
      fill_in "Title", with: "Manager Created Task"
      click_button "Create Task"
      expect(page).to have_text("Task was successfully created")
    end

    it "deletes a task in their managed project" do
      expect {
        page.driver.submit(:delete, organization_project_task_path(organization, project_alpha, task_in_alpha), {})
      }.to change(Task, :count).by(-1)
    end
  end

  context "as project member" do
    let(:user) { create(:user) }

    before do
      create(:organization_membership, user:, organization:, role: :member)
      create(:project_member, user:, project: project_alpha, role: :member)
      sign_in_as(user)
    end

    include_context "with projects and tasks"

    it "sees only their project in the list" do
      visit organization_projects_path(organization)
      expect(page).to have_text("Alpha")
      expect(page).not_to have_text("Beta")
    end

    it "accesses their own project show page" do
      visit organization_project_path(organization, project_alpha)
      expect(page).to have_text("Alpha")
    end

    it "cannot access another project show page" do
      visit organization_project_path(organization, project_beta)
      expect(page).to have_text("not authorized")
    end

    it "cannot edit their project" do
      visit edit_organization_project_path(organization, project_alpha)
      expect(page).to have_text(/not authorized/i)
    end

    it "sees tasks in their project" do
      visit organization_project_tasks_path(organization, project_alpha)
      expect(page).to have_text("Alpha Task")
    end

    it "cannot see tasks in another project" do
      visit organization_project_tasks_path(organization, project_beta)
      expect(page).not_to have_text("Alpha Task")
      expect(page).not_to have_text("Beta Task")
    end

    it "creates a task in their project" do
      visit new_organization_project_task_path(organization, project_alpha)
      fill_in "Title", with: "My New Task"
      click_button "Create Task"
      expect(page).to have_text("Task was successfully created")
    end

    it "cannot delete a task" do
      expect {
        page.driver.submit(:delete, organization_project_task_path(organization, project_alpha, task_in_alpha), {})
      }.not_to change(Task, :count)
    end
  end

  context "as org member without project membership" do
    let(:user) { create(:user) }

    before do
      create(:organization_membership, user:, organization:, role: :member)
      sign_in_as(user)
    end

    include_context "with projects and tasks"

    it "sees no projects in the list" do
      visit organization_projects_path(organization)
      expect(page).not_to have_text("Alpha")
      expect(page).not_to have_text("Beta")
    end

    it "cannot access any project show page" do
      visit organization_project_path(organization, project_alpha)
      expect(page).to have_text("not authorized")
    end

    it "cannot access task list in any project" do
      visit organization_project_tasks_path(organization, project_alpha)
      expect(page).not_to have_text("Alpha Task")
    end

    it "cannot create tasks" do
      visit new_organization_project_task_path(organization, project_alpha)
      expect(page).to have_text("not authorized")
    end
  end

  context "as non-member" do
    let(:user) { create(:user) }

    before do
      sign_in_as(user)
    end

    include_context "with projects and tasks"

    it "cannot see projects" do
      visit organization_projects_path(organization)
      expect(page).not_to have_text("Alpha")
      expect(page).not_to have_text("Beta")
    end

    it "cannot access project show page" do
      visit organization_project_path(organization, project_alpha)
      expect(page).not_to have_text("Alpha")
      expect(current_path).to eq(new_organization_path)
    end

    it "cannot access tasks" do
      visit organization_project_tasks_path(organization, project_alpha)
      expect(page).not_to have_text("Alpha Task")
    end
  end
end
