require "rails_helper"

RSpec.describe Task, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      task = build(:task)
      expect(task).to be_valid
    end

    it "requires a title" do
      task = build(:task, title: nil)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to project" do
      project = create(:project)
      task = create(:task, project: project)
      expect(task.project).to eq(project)
    end

    it "has many checklist items" do
      task = create(:task)
      item = task.checklist_items.create!(content: "Test item")
      expect(task.checklist_items).to include(item)
    end

    it "has many comments" do
      task = create(:task)
      user = create(:user)
      comment = task.comments.create!(content: "Test comment", user: user)
      expect(task.comments).to include(comment)
    end
  end

  describe "enums" do
    it "defines statuses including kanban columns" do
      expect(Task.statuses).to include("backlog", "todo", "in_progress", "in_review", "done")
    end
  end

  describe "recurrence" do
    it "is not recurring by default" do
      task = build(:task)
      expect(task).not_to be_recurring
    end

    it "is recurring when rule is set" do
      task = build(:task, recurrence_rule: "weekly")
      expect(task).to be_recurring
    end

    it "validates recurrence_rule inclusion" do
      task = build(:task, recurrence_rule: "invalid")
      expect(task).not_to be_valid
    end

    it "provides next_due_date for daily" do
      task = build(:task, due_date: Date.new(2026, 7, 1), recurrence_rule: "daily")
      expect(task.next_due_date).to eq(Date.new(2026, 7, 2))
    end

    it "provides next_due_date for weekly" do
      task = build(:task, due_date: Date.new(2026, 7, 1), recurrence_rule: "weekly")
      expect(task.next_due_date).to eq(Date.new(2026, 7, 8))
    end

    it "provides next_due_date for weekdays (skips weekend)" do
      friday = Date.new(2026, 7, 3)
      task = build(:task, due_date: friday, recurrence_rule: "weekdays")
      expect(task.next_due_date).to eq(Date.new(2026, 7, 6))
    end

    it "provides next_due_date for monthly" do
      task = build(:task, due_date: Date.new(2026, 7, 1), recurrence_rule: "monthly")
      expect(task.next_due_date).to eq(Date.new(2026, 8, 1))
    end

    it "returns nil for next_due_date when end_date has passed" do
      task = build(:task, due_date: 2.days.ago, recurrence_rule: "weekly", recurrence_end_date: 1.day.ago)
      expect(task.next_due_date).to be_nil
    end

    it "provides recurrence_label" do
      task = build(:task, recurrence_rule: "weekly")
      expect(task.recurrence_label).to eq("Weekly")
    end

    it "scopes recurring_active" do
      create(:task, recurrence_rule: "weekly")
      create(:task, recurrence_rule: "daily", recurrence_end_date: 1.day.ago)
      expect(Task.recurring_active.count).to eq(1)
    end
  end
end
