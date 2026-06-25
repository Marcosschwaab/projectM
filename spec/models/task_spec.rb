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
end
