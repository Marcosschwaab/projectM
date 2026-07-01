require "rails_helper"

RSpec.describe TaskDependency, type: :model do
  describe "validations" do
    it "validates uniqueness of dependency scoped to task" do
      task = create(:task)
      dep = create(:task)
      create(:task_dependency, task: task, dependency: dep)
      duplicate = build(:task_dependency, task: task, dependency: dep)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:dependency_id]).to include("has already been taken")
    end

    it "prevents self-referencing dependency" do
      task = create(:task)
      dep = build(:task_dependency, task: task, dependency: task)
      expect(dep).not_to be_valid
      expect(dep.errors[:dependency]).to include("cannot depend on itself")
    end

    it "prevents circular dependency" do
      task_a = create(:task)
      task_b = create(:task)
      create(:task_dependency, task: task_a, dependency: task_b)
      circular = build(:task_dependency, task: task_b, dependency: task_a)
      expect(circular).not_to be_valid
      expect(circular.errors[:dependency]).to include("circular dependency detected")
    end
  end

  describe "associations" do
    it "belongs to task" do
      dep = create(:task_dependency)
      expect(dep.task).to be_a(Task)
    end

    it "belongs to dependency" do
      dep = create(:task_dependency)
      expect(dep.dependency).to be_a(Task)
    end
  end
end
