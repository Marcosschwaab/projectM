require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:task) { create(:task, project: project) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "GET /organizations/:id/projects/:id/tasks" do
    it "returns http success" do
      get organization_project_tasks_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/projects/:id/tasks/:id" do
    it "returns http success" do
      get organization_project_task_path(organization, project, task)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/projects/:id/tasks/new" do
    it "returns http success" do
      get new_organization_project_task_path(organization, project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /organizations/:id/projects/:id/tasks/:id/edit" do
    it "returns http success" do
      get edit_organization_project_task_path(organization, project, task)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /organizations/:id/projects/:id/tasks" do
    it "creates a new task" do
      expect {
        post organization_project_tasks_path(organization, project), params: { task: { title: "New task" } }
      }.to change(Task, :count).by(1)
    end

    it "renders new on failure" do
      expect {
        post organization_project_tasks_path(organization, project), params: { task: { title: "" } }
      }.not_to change(Task, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "creates notification when assigned to different user" do
      other_user = create(:user)
      create(:organization_membership, user: other_user, organization: organization, role: :member)
      post organization_project_tasks_path(organization, project), params: { task: { title: "New task", assignee_id: other_user.id } }
      expect(other_user.notifications.count).to eq(1)
    end
  end

  describe "PATCH /organizations/:id/projects/:id/tasks/:id" do
    it "updates the task" do
      patch organization_project_task_path(organization, project, task), params: { task: { title: "Updated" } }
      expect(task.reload.title).to eq("Updated")
    end

    it "renders edit on failure" do
      patch organization_project_task_path(organization, project, task), params: { task: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "creates notification when assignee changes" do
      other_user = create(:user)
      create(:organization_membership, user: other_user, organization: organization, role: :member)
      patch organization_project_task_path(organization, project, task), params: { task: { assignee_id: other_user.id } }
      expect(other_user.notifications.count).to eq(1)
    end
  end

  describe "DELETE /organizations/:id/projects/:id/tasks/:id" do
    it "deletes the task" do
      task
      expect {
        delete organization_project_task_path(organization, project, task)
      }.to change(Task, :count).by(-1)
    end
  end

  describe "PATCH /organizations/:id/projects/:id/tasks/:id/move" do
    it "updates task status" do
      patch move_organization_project_task_path(organization, project, task), params: { status: "done" }
      expect(task.reload.status).to eq("done")
    end

    it "creates notification when assignee exists" do
      other_user = create(:user)
      create(:organization_membership, user: other_user, organization: organization, role: :member)
      task.update!(assignee: other_user)
      patch move_organization_project_task_path(organization, project, task), params: { status: "done" }
      expect(other_user.notifications.count).to eq(1)
    end

    it "returns error on invalid position" do
      patch move_organization_project_task_path(organization, project, task), params: { status: "done", position: -1 }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /organizations/:id/projects/:id/tasks/:id/modal" do
    it "returns http success" do
      get modal_organization_project_task_path(organization, project, task)
      expect(response).to have_http_status(:success)
    end
  end
end
