require "rails_helper"

RSpec.describe Notification, type: :model do
  describe "associations" do
    it "belongs to recipient" do
      notification = create(:notification)
      expect(notification.recipient).to be_a(User)
    end

    it "belongs to actor" do
      notification = create(:notification)
      expect(notification.actor).to be_a(User)
    end

    it "belongs to notifiable polymorphic" do
      notification = create(:notification, notifiable: create(:task))
      expect(notification.notifiable).to be_a(Task)
    end

    it "belongs to organization" do
      notification = create(:notification)
      expect(notification.organization).to be_a(Organization)
    end
  end

  describe "scopes" do
    it "unread returns notifications where read is false" do
      unread = create(:notification, read: false)
      read = create(:notification, read: true)
      expect(Notification.unread).to include(unread)
      expect(Notification.unread).not_to include(read)
    end

    it "recent orders by created_at desc" do
      old = create(:notification, created_at: 1.day.ago)
      new = create(:notification, created_at: Time.current)
      expect(Notification.recent.first).to eq(new)
    end

    it "latest returns 5 most recent" do
      create_list(:notification, 7)
      expect(Notification.latest.count).to eq(5)
    end
  end

  describe "#mark_read!" do
    it "marks notification as read with timestamp" do
      notification = create(:notification, read: false)
      notification.mark_read!
      expect(notification.read).to be true
      expect(notification.read_at).to be_present
    end
  end

  describe "#icon" do
    it "returns correct icon for task_assigned" do
      notification = build(:notification, action: "task_assigned")
      expect(notification.icon).to eq("user-plus")
    end

    it "returns correct icon for task_commented" do
      notification = build(:notification, action: "task_commented")
      expect(notification.icon).to eq("message-square")
    end

    it "returns correct icon for task_moved" do
      notification = build(:notification, action: "task_moved")
      expect(notification.icon).to eq("arrow-right")
    end

    it "returns correct icon for task_updated" do
      notification = build(:notification, action: "task_updated")
      expect(notification.icon).to eq("edit")
    end

    it "returns correct icon for project_archived" do
      notification = build(:notification, action: "project_archived")
      expect(notification.icon).to eq("archive")
    end

    it "returns default bell for unknown actions" do
      notification = build(:notification, action: "unknown")
      expect(notification.icon).to eq("bell")
    end
  end

  describe "#description" do
    it "returns correct description for task_assigned" do
      notification = build(:notification, action: "task_assigned")
      expect(notification.description).to eq("assigned you to")
    end

    it "returns correct description for task_commented" do
      notification = build(:notification, action: "task_commented")
      expect(notification.description).to eq("commented on")
    end

    it "returns correct description for task_moved" do
      notification = build(:notification, action: "task_moved")
      expect(notification.description).to eq("moved")
    end

    it "returns correct description for task_updated" do
      notification = build(:notification, action: "task_updated")
      expect(notification.description).to eq("updated")
    end

    it "returns correct description for project_archived" do
      notification = build(:notification, action: "project_archived")
      expect(notification.description).to eq("archived")
    end

    it "humanizes and downcases unknown actions" do
      notification = build(:notification, action: "something_happened")
      expect(notification.description).to eq("something happened")
    end
  end
end
