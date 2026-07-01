require "rails_helper"

RSpec.describe Kpi, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      kpi = build(:kpi)
      expect(kpi).to be_valid
    end

    it "requires a name" do
      kpi = build(:kpi, name: nil)
      expect(kpi).not_to be_valid
      expect(kpi.errors[:name]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to organization" do
      kpi = create(:kpi)
      expect(kpi.organization).to be_a(Organization)
    end

    it "belongs to project" do
      project = create(:project)
      kpi = create(:kpi, project: project)
      expect(kpi.project).to eq(project)
    end

    it "belongs to owner" do
      owner = create(:user)
      kpi = create(:kpi, owner: owner)
      expect(kpi.owner).to eq(owner)
    end
  end

  describe "enums" do
    it "defines categories" do
      expect(Kpi.categories).to include("strategic", "project", "quality", "operational", "financial")
    end

    it "defines frequencies" do
      expect(Kpi.frequencies).to include("daily", "weekly", "monthly", "quarterly", "yearly")
    end

    it "defines trends" do
      expect(Kpi.trends).to include("flat", "up", "down")
    end
  end

  describe "scopes" do
    it "org_wide returns KPIs without a project" do
      org_wide = create(:kpi, project: nil)
      project_kpi = create(:kpi, project: create(:project))
      expect(Kpi.org_wide).to include(org_wide)
      expect(Kpi.org_wide).not_to include(project_kpi)
    end

    it "by_project filters by project" do
      project = create(:project)
      kpi = create(:kpi, project: project)
      other = create(:kpi, project: create(:project))
      expect(Kpi.by_project(project)).to include(kpi)
      expect(Kpi.by_project(project)).not_to include(other)
    end
  end

  describe "#calculate_progress" do
    it "returns 0 when target_value is nil" do
      kpi = build(:kpi, target_value: nil)
      expect(kpi.calculate_progress).to eq(0)
    end

    it "returns correct percentage" do
      kpi = build(:kpi, target_value: 100, current_value: 75)
      expect(kpi.calculate_progress).to eq(75.0)
    end
  end

  describe "#status" do
    it "returns achieved when progress >= 100" do
      kpi = build(:kpi, target_value: 100, current_value: 100)
      expect(kpi.status).to eq("achieved")
    end

    it "returns on_track when progress >= 75" do
      kpi = build(:kpi, target_value: 100, current_value: 75)
      expect(kpi.status).to eq("on_track")
    end

    it "returns at_risk when progress >= 50" do
      kpi = build(:kpi, target_value: 100, current_value: 50)
      expect(kpi.status).to eq("at_risk")
    end

    it "returns behind when progress >= 25" do
      kpi = build(:kpi, target_value: 100, current_value: 25)
      expect(kpi.status).to eq("behind")
    end

    it "returns critical when progress < 25" do
      kpi = build(:kpi, target_value: 100, current_value: 10)
      expect(kpi.status).to eq("critical")
    end
  end

  describe ".calculate_trend" do
    it "returns flat when previous is nil" do
      expect(Kpi.calculate_trend(current: 50, previous: nil)).to eq("flat")
    end

    it "returns flat when previous is zero" do
      expect(Kpi.calculate_trend(current: 50, previous: 0)).to eq("flat")
    end

    it "returns up when current > previous" do
      expect(Kpi.calculate_trend(current: 60, previous: 40)).to eq("up")
    end

    it "returns down when current < previous" do
      expect(Kpi.calculate_trend(current: 30, previous: 70)).to eq("down")
    end

    it "returns flat when equal" do
      expect(Kpi.calculate_trend(current: 50, previous: 50)).to eq("flat")
    end
  end
end
