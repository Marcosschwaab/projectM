require "rails_helper"

RSpec.describe Program, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      program = build(:program)
      expect(program).to be_valid
    end

    it "requires a name" do
      program = build(:program, name: nil)
      expect(program).not_to be_valid
      expect(program.errors[:name]).to include("can't be blank")
    end

    it "rejects invalid status" do
      expect { build(:program, status: "invalid") }.to raise_error(ArgumentError)
    end
  end

  describe "associations" do
    it "belongs to organization" do
      program = create(:program)
      expect(program.organization).to be_a(Organization)
    end

    it "has many projects" do
      program = create(:program)
      project = create(:project, program: program, organization: program.organization)
      expect(program.projects).to include(project)
    end

    it "has many objectives through projects" do
      program = create(:program)
      project = create(:project, program: program, organization: program.organization)
      okr_cycle = create(:okr_cycle, organization: program.organization)
      objective = create(:objective, okr_cycle: okr_cycle, project: project)
      expect(program.objectives).to include(objective)
    end

    it "has many kpis through projects" do
      program = create(:program)
      project = create(:project, program: program, organization: program.organization)
      kpi = create(:kpi, organization: program.organization, project: project)
      expect(program.kpis).to include(kpi)
    end
  end

  describe "#progress" do
    it "returns 0 when no active projects" do
      program = create(:program)
      expect(program.progress).to eq(0)
    end

    it "calculates average progress of active projects" do
      program = create(:program)
      create(:project, program: program, organization: program.organization)
      expect(program.progress).to be >= 0
    end
  end

  describe "rollup methods" do
    let(:organization) { create(:organization) }
    let(:program) { create(:program, organization: organization) }

    before do
      project = create(:project, organization: organization, program: program)
      create(:task, project: project, status: :done)
      create(:task, project: project, status: :todo)
    end

    it "#tasks_count" do
      expect(program.tasks_count).to eq(2)
    end

    it "#tasks_done_count" do
      expect(program.tasks_done_count).to eq(1)
    end

    it "#risks_count" do
      project = program.projects.first
      create(:risk, project: project)
      expect(program.risks_count).to eq(1)
    end
  end
end
