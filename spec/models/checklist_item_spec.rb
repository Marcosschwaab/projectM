require "rails_helper"

RSpec.describe ChecklistItem, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      item = build(:checklist_item)
      expect(item).to be_valid
    end

    it "requires content" do
      item = build(:checklist_item, content: nil)
      expect(item).not_to be_valid
      expect(item.errors[:content]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to task" do
      item = create(:checklist_item)
      expect(item.task).to be_a(Task)
    end
  end
end
