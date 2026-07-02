require "rails_helper"

RSpec.describe "TimeEntries", type: :request do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:project) { create(:project, organization: organization) }
  let(:task) { create(:task, project: project) }

  before do
    create(:organization_membership, user: user, organization: organization, role: :admin)
    sign_in user
  end

  describe "POST /organizations/:id/projects/:id/tasks/:id/time_entries/start" do
    it "starts a timer" do
      expect {
        post start_organization_project_task_time_entries_path(organization, project, task)
      }.to change(TimeEntry, :count).by(1)

      entry = TimeEntry.last
      expect(entry.user).to eq(user)
      expect(entry.task).to eq(task)
      expect(entry.ended_at).to be_nil
    end

    it "redirects after starting" do
      post start_organization_project_task_time_entries_path(organization, project, task)
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "PATCH /organizations/:id/projects/:id/tasks/:id/time_entries/stop" do
    it "stops the running timer" do
      entry = create(:time_entry, task: task, user: user, started_at: 1.hour.ago, ended_at: nil, duration: nil)

      expect {
        patch stop_organization_project_task_time_entries_path(organization, project, task)
      }.to change { entry.reload.ended_at }.from(nil)
    end
  end

  describe "POST /organizations/:id/projects/:id/tasks/:id/time_entries" do
    it "creates a manual time entry" do
      expect {
        post organization_project_task_time_entries_path(organization, project, task), params: {
          time_entry: { started_at: 2.hours.ago, duration: 120, description: "Work" }
        }
      }.to change(TimeEntry, :count).by(1)

      entry = TimeEntry.last
      expect(entry.user).to eq(user)
      expect(entry.duration).to eq(120)
      expect(entry.description).to eq("Work")
    end
  end

  describe "DELETE /organizations/:id/projects/:id/tasks/:id/time_entries/:id" do
    it "deletes a time entry" do
      entry = create(:time_entry, task: task, user: user)

      expect {
        delete organization_project_task_time_entry_path(organization, project, task, entry)
      }.to change(TimeEntry, :count).by(-1)
    end
  end
end
