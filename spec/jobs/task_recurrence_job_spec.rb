require "rails_helper"

RSpec.describe TaskRecurrenceJob, type: :job do
  describe "#perform" do
    let(:project) { create(:project) }

    it "creates next instance of a recurring task" do
      task = create(:task, project: project, due_date: Date.yesterday, recurrence_rule: "daily")

      expect {
        described_class.perform_now
      }.to change(Task, :count).by(1)

      child = Task.last
      expect(child.title).to eq(task.title)
      expect(child.due_date).to eq(Date.today)
      expect(child.recurring_parent).to eq(task)
      expect(child.recurrence_rule).to be_nil
    end

    it "does not create duplicate instances" do
      task = create(:task, project: project, due_date: Date.yesterday, recurrence_rule: "daily")
      create(:task, project: project, due_date: Date.today, recurring_parent: task)

      expect {
        described_class.perform_now
      }.not_to change(Task, :count)
    end

    it "skips tasks without due_date" do
      create(:task, project: project, due_date: nil, recurrence_rule: "daily")

      expect {
        described_class.perform_now
      }.not_to change(Task, :count)
    end

    it "skips child tasks (recurring_parent present)" do
      parent = create(:task, project: project, due_date: Date.yesterday, recurrence_rule: "daily")
      create(:task, project: project, due_date: Date.today, recurring_parent: parent, recurrence_rule: "daily")

      expect {
        described_class.perform_now
      }.not_to change(Task, :count)
    end

    it "skips tasks past their end_date" do
      create(:task, project: project, due_date: 2.days.ago, recurrence_rule: "daily", recurrence_end_date: 1.day.ago)

      expect {
        described_class.perform_now
      }.not_to change(Task, :count)
    end

    it "copies tags to the child task" do
      tag = create(:tag)
      task = create(:task, project: project, due_date: Date.yesterday, recurrence_rule: "daily")
      task.tags << tag

      described_class.perform_now

      child = Task.last
      expect(child.tags).to include(tag)
    end
  end
end
