require "rails_helper"

RSpec.describe Objective, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      objective = build(:objective)
      expect(objective).to be_valid
    end

    it "requires a title" do
      objective = build(:objective, title: nil)
      expect(objective).not_to be_valid
      expect(objective.errors[:title]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to okr_cycle" do
      objective = create(:objective)
      expect(objective.okr_cycle).to be_a(OkrCycle)
    end

    it "belongs to owner" do
      owner = create(:user)
      objective = create(:objective, owner: owner)
      expect(objective.owner).to eq(owner)
    end

    it "belongs to project" do
      project = create(:project)
      objective = create(:objective, project: project)
      expect(objective.project).to eq(project)
    end

    it "has many key_results" do
      objective = create(:objective)
      kr = create(:key_result, objective: objective)
      expect(objective.key_results).to include(kr)
    end
  end

  describe "scopes" do
    it "linked_to_project returns objectives with project" do
      linked = create(:objective, project: create(:project))
      unlinked = create(:objective, project: nil)
      expect(Objective.linked_to_project).to include(linked)
      expect(Objective.linked_to_project).not_to include(unlinked)
    end

    it "unlinked returns objectives without project" do
      linked = create(:objective, project: create(:project))
      unlinked = create(:objective, project: nil)
      expect(Objective.unlinked).to include(unlinked)
      expect(Objective.unlinked).not_to include(linked)
    end
  end

  describe "#calculate_progress" do
    it "returns 0 when no key results exist" do
      objective = create(:objective)
      expect(objective.calculate_progress).to eq(0)
    end

    it "returns average progress of key results" do
      objective = create(:objective)
      create(:key_result, objective: objective, target_value: 100, current_value: 80)
      create(:key_result, objective: objective, target_value: 100, current_value: 40)
      expect(objective.calculate_progress).to eq(60.0)
    end
  end

  describe "#update_progress!" do
    it "updates the progress attribute" do
      objective = create(:objective)
      create(:key_result, objective: objective, target_value: 100, current_value: 50)
      objective.update_progress!
      expect(objective.reload.progress).to eq(50.0)
    end
  end
end
