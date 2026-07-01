require "rails_helper"

RSpec.describe ActivityLog, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      log = build(:activity_log)
      expect(log).to be_valid
    end

    it "requires an action" do
      log = build(:activity_log, action: nil)
      expect(log).not_to be_valid
      expect(log.errors[:action]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to user" do
      log = create(:activity_log)
      expect(log.user).to be_a(User)
    end

    it "belongs to organization" do
      log = create(:activity_log)
      expect(log.organization).to be_a(Organization)
    end

    it "belongs to trackable polymorphic" do
      log = create(:activity_log, trackable: create(:task))
      expect(log.trackable).to be_a(Task)
    end
  end
end
