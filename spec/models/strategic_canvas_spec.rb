require "rails_helper"

RSpec.describe StrategicCanvas, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      canvas = build(:strategic_canvas)
      expect(canvas).to be_valid
    end

    it "requires a goal" do
      canvas = build(:strategic_canvas, goal: nil)
      expect(canvas).not_to be_valid
      expect(canvas.errors[:goal]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to project" do
      canvas = create(:strategic_canvas)
      expect(canvas.project).to be_a(Project)
    end
  end
end
