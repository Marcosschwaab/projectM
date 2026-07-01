require "rails_helper"

RSpec.describe KeyResult, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      kr = build(:key_result)
      expect(kr).to be_valid
    end

    it "requires a title" do
      kr = build(:key_result, title: nil)
      expect(kr).not_to be_valid
      expect(kr.errors[:title]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to objective" do
      kr = create(:key_result)
      expect(kr.objective).to be_a(Objective)
    end
  end

  describe "#calculate_progress" do
    it "returns 0 when target_value is nil" do
      kr = build(:key_result, target_value: nil)
      expect(kr.calculate_progress).to eq(0)
    end

    it "returns 0 when target_value is zero" do
      kr = build(:key_result, target_value: 0)
      expect(kr.calculate_progress).to eq(0)
    end

    it "returns correct percentage" do
      kr = build(:key_result, target_value: 200, current_value: 50)
      expect(kr.calculate_progress).to eq(25.0)
    end
  end

  describe "#update_progress!" do
    it "updates own progress and cascades to objective" do
      objective = create(:objective)
      kr = create(:key_result, objective: objective, target_value: 100, current_value: 75)
      kr.update_progress!
      expect(kr.reload.progress).to eq(75.0)
      expect(objective.reload.progress).to eq(75.0)
    end
  end

  describe "#remaining" do
    it "returns 0 when target_value is blank" do
      kr = build(:key_result, target_value: nil)
      expect(kr.remaining).to eq(0)
    end

    it "returns remaining value" do
      kr = build(:key_result, target_value: 100, current_value: 30)
      expect(kr.remaining).to eq(70)
    end

    it "returns 0 when exceeded" do
      kr = build(:key_result, target_value: 100, current_value: 150)
      expect(kr.remaining).to eq(0)
    end
  end
end
