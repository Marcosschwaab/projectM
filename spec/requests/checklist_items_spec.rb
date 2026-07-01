require "rails_helper"

RSpec.describe "ChecklistItems", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:task) { create(:task, project: project) }
  let(:checklist_item) { create(:checklist_item, task: task) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "POST /organizations/:id/projects/:id/tasks/:id/checklist_items" do
    it "creates a new checklist item" do
      expect {
        post organization_project_task_checklist_items_path(organization, project, task), params: { checklist_item: { content: "Subtask" } }
      }.to change(ChecklistItem, :count).by(1)
    end

    it "redirects on failure" do
      expect {
        post organization_project_task_checklist_items_path(organization, project, task), params: { checklist_item: { content: "" } }
      }.not_to change(ChecklistItem, :count)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "PATCH /organizations/:id/projects/:id/tasks/:id/checklist_items/:id" do
    it "updates the checklist item" do
      patch organization_project_task_checklist_item_path(organization, project, task, checklist_item), params: { checklist_item: { completed: true } }
      expect(checklist_item.reload.completed).to be true
    end
  end

  describe "DELETE /organizations/:id/projects/:id/tasks/:id/checklist_items/:id" do
    it "deletes the checklist item" do
      checklist_item
      expect {
        delete organization_project_task_checklist_item_path(organization, project, task, checklist_item)
      }.to change(ChecklistItem, :count).by(-1)
    end
  end
end
