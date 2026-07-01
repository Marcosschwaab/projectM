require "rails_helper"

RSpec.describe "Notifications", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /notifications" do
    it "returns http success" do
      get notifications_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /notifications/:id/mark_read" do
    it "marks a notification as read" do
      notification = create(:notification, recipient: user)
      patch mark_read_notification_path(notification)
      expect(notification.reload.read).to be true
    end
  end

  describe "PATCH /notifications/mark_all_read" do
    it "marks all notifications as read" do
      create(:notification, recipient: user, read: false)
      create(:notification, recipient: user, read: false)
      patch mark_all_read_notifications_path
      expect(user.notifications.unread.count).to eq(0)
    end
  end
end
