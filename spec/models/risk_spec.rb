require "rails_helper"

RSpec.describe Risk, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      risk = build(:risk)
      expect(risk).to be_valid
    end

    it "requires a name" do
      risk = build(:risk, name: nil)
      expect(risk).not_to be_valid
      expect(risk.errors[:name]).to include("can't be blank")
    end

    it "requires probability to be between 1 and 5" do
      risk = build(:risk, probability: 6)
      expect(risk).not_to be_valid
      expect(risk.errors[:probability]).to include("must be in 1..5")
    end

    it "requires impact to be between 1 and 5" do
      risk = build(:risk, impact: 0)
      expect(risk).not_to be_valid
      expect(risk.errors[:impact]).to include("must be in 1..5")
    end

    it "requires a valid status" do
      risk = build(:risk, status: :invalid)
      expect(risk).not_to be_valid
      expect(risk.errors[:status]).to include("is not included in the list")
    end
  end

  describe "associations" do
    it "belongs to project" do
      project = create(:project)
      risk = create(:risk, project: project)
      expect(risk.project).to eq(project)
    end

    it "delegates organization to project" do
      risk = create(:risk)
      expect(risk.organization).to eq(risk.project.organization)
    end

    it "belongs to owner (optional)" do
      risk = create(:risk, owner: nil)
      expect(risk).to be_valid
    end

    it "belongs to owner" do
      owner = create(:user)
      risk = create(:risk, owner: owner)
      expect(risk.owner).to eq(owner)
    end
  end

  describe "enums" do
    it "defines statuses" do
      expect(Risk::STATUSES).to contain_exactly("identified", "assessing", "mitigating", "monitored", "closed")
    end

    it "defines probability levels" do
      expect(Risk::PROBABILITY_LEVELS).to eq(1..5)
    end

    it "defines impact levels" do
      expect(Risk::IMPACT_LEVELS).to eq(1..5)
    end
  end

  describe "scopes" do
    it "by_severity orders by probability * impact descending" do
      low = create(:risk, probability: 1, impact: 1)
      high = create(:risk, probability: 5, impact: 5)
      medium = create(:risk, probability: 3, impact: 3)
      expect(Risk.by_severity).to eq([high, medium, low])
    end

    it "open excludes closed risks" do
      open_risk = create(:risk, status: :identified)
      closed = create(:risk, status: :closed)
      expect(Risk.open).to include(open_risk)
      expect(Risk.open).not_to include(closed)
    end
  end

  describe "#severity" do
    it "returns probability * impact" do
      risk = build(:risk, probability: 4, impact: 3)
      expect(risk.severity).to eq(12)
    end
  end

  describe "#severity_label" do
    it "returns low for severity 1-3" do
      expect(build(:risk, probability: 1, impact: 1).severity_label).to eq("low")
      expect(build(:risk, probability: 1, impact: 3).severity_label).to eq("low")
    end

    it "returns medium for severity 4-6" do
      expect(build(:risk, probability: 2, impact: 2).severity_label).to eq("medium")
      expect(build(:risk, probability: 3, impact: 2).severity_label).to eq("medium")
    end

    it "returns high for severity 7-12" do
      expect(build(:risk, probability: 3, impact: 3).severity_label).to eq("high")
      expect(build(:risk, probability: 4, impact: 3).severity_label).to eq("high")
    end

    it "returns critical for severity 13+ (15, 20, 25)" do
      expect(build(:risk, probability: 5, impact: 3).severity_label).to eq("critical")
      expect(build(:risk, probability: 5, impact: 5).severity_label).to eq("critical")
    end
  end

  describe "#probability_label" do
    Risk::PROBABILITY_LEVELS.each do |level|
      labels = { 1 => "very_low", 2 => "low", 3 => "medium", 4 => "high", 5 => "very_high" }
      it "returns #{labels[level]} for #{level}" do
        expect(build(:risk, probability: level).probability_label).to eq(labels[level])
      end
    end
  end

  describe "#impact_label" do
    Risk::IMPACT_LEVELS.each do |level|
      labels = { 1 => "very_low", 2 => "low", 3 => "medium", 4 => "high", 5 => "very_high" }
      it "returns #{labels[level]} for #{level}" do
        expect(build(:risk, impact: level).impact_label).to eq(labels[level])
      end
    end
  end
end