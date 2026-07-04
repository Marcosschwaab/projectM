require "rails_helper"

RSpec.describe "MyTasks", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :member)
    create(:project_member, user: user, project: project, role: :member)
    sign_in user
  end

  describe "GET /my_tasks" do
    it "returns http success" do
      get my_tasks_path
      expect(response).to have_http_status(:success)
    end

    it "shows tasks assigned to current user" do
      my_task = create(:task, project: project, assignee: user, title: "My Task")
      other_task = create(:task, project: project, title: "Not Mine")
      get my_tasks_path
      expect(response.body).to include("My Task")
      expect(response.body).not_to include("Not Mine")
    end

    it "filters by project" do
      other_project = create(:project, organization: organization)
      create(:project_member, user: user, project: other_project, role: :member)
      task_in_project = create(:task, project: project, assignee: user)
      task_in_other = create(:task, project: other_project, assignee: user)
      get my_tasks_path, params: { project_id: project.id }
      expect(response.body).to include(task_in_project.title)
      expect(response.body).not_to include(task_in_other.title)
    end

    it "filters by priority" do
      high = create(:task, project: project, assignee: user, priority: :high)
      low = create(:task, project: project, assignee: user, priority: :low)
      get my_tasks_path, params: { priority: "high" }
      expect(response.body).to include(high.title)
      expect(response.body).not_to include(low.title)
    end

    it "filters by status" do
      done = create(:task, project: project, assignee: user, status: :done)
      todo = create(:task, project: project, assignee: user, status: :todo)
      get my_tasks_path, params: { status: "done" }
      expect(response.body).to include(done.title)
      expect(response.body).not_to include(todo.title)
    end

    it "shows empty state when no tasks assigned" do
      get my_tasks_path
      expect(response.body).to include(I18n.t("my_tasks.empty"))
    end
  end
end
