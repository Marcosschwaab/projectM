require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:assignee) { create(:user) }
  let(:task) { create(:task, project: project, assignee: assignee) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "POST /organizations/:id/projects/:id/tasks/:id/comments" do
    it "creates a new comment" do
      expect {
        post organization_project_task_comments_path(organization, project, task), params: { comment: { content: "Nice work" } }
      }.to change(Comment, :count).by(1)
    end

    it "redirects on failure" do
      expect {
        post organization_project_task_comments_path(organization, project, task), params: { comment: { content: "" } }
      }.not_to change(Comment, :count)
      expect(response).to have_http_status(:redirect)
    end

    it "creates notification for assignee" do
      create(:organization_membership, user: assignee, organization: organization, role: :member)
      post organization_project_task_comments_path(organization, project, task), params: { comment: { content: "Nice work" } }
      expect(assignee.notifications.count).to eq(1)
    end
  end
end
