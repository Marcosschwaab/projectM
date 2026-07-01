require "rails_helper"

RSpec.describe Project, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      project = build(:project)
      expect(project).to be_valid
    end

    it "requires a name" do
      project = build(:project, name: nil)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to organization" do
      org = create(:organization)
      project = create(:project, organization: org)
      expect(project.organization).to eq(org)
    end

    it "has many tasks" do
      project = create(:project)
      task = create(:task, project: project)
      expect(project.tasks).to include(task)
    end

    it "has one strategic canvas" do
      project = create(:project)
      canvas = project.create_strategic_canvas!(goal: "Achieve market leadership")
      expect(project.strategic_canvas).to eq(canvas)
    end
  end

  describe "scopes" do
    let!(:active_project) { create(:project, archived: false) }
    let!(:archived_project) { create(:project, archived: true) }

    it "returns active projects" do
      expect(Project.active).to include(active_project)
      expect(Project.active).not_to include(archived_project)
    end

    it "returns archived projects" do
      expect(Project.archived).to include(archived_project)
      expect(Project.archived).not_to include(active_project)
    end
  end

  describe "enums" do
    it "defines priorities" do
      expect(Project.priorities).to include("low", "medium", "high", "urgent")
    end

    it "defines statuses" do
      expect(Project.statuses).to include("on_track", "at_risk", "behind", "on_hold", "completed")
    end
  end
end
