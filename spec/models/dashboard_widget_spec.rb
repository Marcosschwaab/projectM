require "rails_helper"

RSpec.describe DashboardWidget, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      widget = build(:dashboard_widget, user: user)
      expect(widget).to be_valid
    end

    it "requires widget_type" do
      widget = build(:dashboard_widget, user: user, widget_type: nil)
      expect(widget).not_to be_valid
    end

    it "validates widget_type inclusion" do
      widget = build(:dashboard_widget, user: user, widget_type: "invalid")
      expect(widget).not_to be_valid
    end

    it "validates width inclusion" do
      widget = build(:dashboard_widget, user: user, width: 5)
      expect(widget).not_to be_valid
    end

    it "requires position" do
      widget = build(:dashboard_widget, user: user, position: nil)
      expect(widget).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe "scopes" do
    it "orders by position" do
      create(:dashboard_widget, user: user, widget_type: "stats", position: 2)
      create(:dashboard_widget, user: user, widget_type: "timeline", position: 0)
      expect(DashboardWidget.ordered.pluck(:position)).to eq([0, 2])
    end

    it "filters visible" do
      visible = create(:dashboard_widget, user: user, widget_type: "stats", visible: true, position: 0)
      hidden = create(:dashboard_widget, user: user, widget_type: "timeline", visible: false, position: 1)
      expect(DashboardWidget.visible).to contain_exactly(visible)
      expect(DashboardWidget.visible).not_to include(hidden)
    end
  end

  describe ".defaults_for" do
    it "creates default widgets for a user" do
      expect {
        described_class.defaults_for(user)
      }.to change(described_class, :count).by(12)
    end

    it "returns the widgets ordered" do
      result = described_class.defaults_for(user)
      expect(result).to all(be_a(described_class))
      expect(result.map(&:position)).to eq((0...12).to_a)
    end

    it "is idempotent" do
      described_class.defaults_for(user)
      expect {
        described_class.defaults_for(user)
      }.not_to change(described_class, :count)
    end
  end
end
