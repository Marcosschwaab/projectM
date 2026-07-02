require "rails_helper"

RSpec.describe TimeEntry, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      entry = build(:time_entry, started_at: 1.hour.ago, ended_at: Time.current)
      expect(entry).to be_valid
    end

    it "requires started_at" do
      entry = build(:time_entry, started_at: nil, ended_at: nil)
      expect(entry).not_to be_valid
      expect(entry.errors[:started_at]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to task" do
      entry = create(:time_entry)
      expect(entry.task).to be_a(Task)
    end

    it "belongs to user" do
      entry = create(:time_entry)
      expect(entry.user).to be_a(User)
    end
  end

  describe "scopes" do
    it "running returns entries without ended_at" do
      running = create(:time_entry, ended_at: nil)
      create(:time_entry, ended_at: Time.current)
      expect(TimeEntry.running).to contain_exactly(running)
    end

    it "stopped returns entries with ended_at" do
      create(:time_entry, ended_at: nil)
      stopped = create(:time_entry, ended_at: Time.current)
      expect(TimeEntry.stopped).to contain_exactly(stopped)
    end
  end

  describe "#stop!" do
    it "sets ended_at and calculates duration" do
      now = Time.current
      entry = create(:time_entry, started_at: now - 2.hours, ended_at: nil, duration: nil)
      entry.stop!
      expect(entry.ended_at).to be_present
      expect(entry.duration).to eq(120)
    end
  end

  describe "#formatted_duration" do
    it "returns hours and minutes" do
      entry = build(:time_entry, duration: 150)
      expect(entry.formatted_duration).to eq("2h 30m")
    end

    it "returns only minutes when less than an hour" do
      entry = build(:time_entry, duration: 45)
      expect(entry.formatted_duration).to eq("45m")
    end
  end
end
