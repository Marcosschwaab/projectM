require "rails_helper"

RSpec.describe OkrCycle, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      cycle = build(:okr_cycle)
      expect(cycle).to be_valid
    end

    it "requires a title" do
      cycle = build(:okr_cycle, title: nil)
      expect(cycle).not_to be_valid
      expect(cycle.errors[:title]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to organization" do
      cycle = create(:okr_cycle)
      expect(cycle.organization).to be_a(Organization)
    end

    it "has many objectives" do
      cycle = create(:okr_cycle)
      objective = create(:objective, okr_cycle: cycle)
      expect(cycle.objectives).to include(objective)
    end

    it "has many key results through objectives" do
      cycle = create(:okr_cycle)
      objective = create(:objective, okr_cycle: cycle)
      kr = create(:key_result, objective: objective)
      expect(cycle.key_results).to include(kr)
    end
  end

  describe "enums" do
    it "defines statuses with default draft" do
      expect(OkrCycle.statuses).to include("draft", "active", "completed", "cancelled")
      expect(OkrCycle.new.status).to eq("draft")
    end
  end

  describe "#overall_progress" do
    it "returns 0 when no objectives exist" do
      cycle = create(:okr_cycle)
      expect(cycle.overall_progress).to eq(0)
    end

    it "returns average progress of all objectives" do
      cycle = create(:okr_cycle)
      objective = create(:objective, okr_cycle: cycle)
      create(:key_result, objective: objective, target_value: 100, current_value: 50)
      objective.update_progress!
      objective.reload
      expect(cycle.overall_progress).to eq(50.0)
    end
  end

  describe "#objectives_completed" do
    it "returns count of objectives at 100% progress" do
      cycle = create(:okr_cycle)
      obj1 = create(:objective, okr_cycle: cycle)
      obj2 = create(:objective, okr_cycle: cycle)
      create(:key_result, objective: obj1, target_value: 100, current_value: 100)
      create(:key_result, objective: obj2, target_value: 100, current_value: 50)
      obj1.update_progress!
      obj1.reload
      obj2.update_progress!
      expect(cycle.objectives_completed).to eq(1)
    end
  end

  describe "#krs_achieved" do
    it "returns count of key results at 100% progress" do
      cycle = create(:okr_cycle)
      objective = create(:objective, okr_cycle: cycle)
      kr1 = create(:key_result, objective: objective, target_value: 100, current_value: 100)
      kr2 = create(:key_result, objective: objective, target_value: 100, current_value: 50)
      expect(cycle.krs_achieved).to eq(1)
    end
  end

  describe "#kr_count" do
    it "returns total number of key results" do
      cycle = create(:okr_cycle)
      objective = create(:objective, okr_cycle: cycle)
      create(:key_result, objective: objective)
      create(:key_result, objective: objective)
      expect(cycle.kr_count).to eq(2)
    end
  end
end
