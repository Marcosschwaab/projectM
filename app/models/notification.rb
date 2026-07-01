class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true
  belongs_to :organization, optional: true

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :latest, -> { recent.limit(5) }

  after_create_commit :broadcast_to_recipient

  def mark_read!
    update!(read: true, read_at: Time.current)
  end

  def icon
    case action
    when "task_assigned" then "user-plus"
    when "task_commented" then "message-square"
    when "task_moved" then "arrow-right"
    when "task_updated" then "edit"
    when "project_archived" then "archive"
    else "bell"
    end
  end

  def description
    case action
    when "task_assigned" then "assigned you to"
    when "task_commented" then "commented on"
    when "task_moved" then "moved"
    when "task_updated" then "updated"
    when "project_archived" then "archived"
    else action.humanize.downcase
    end
  end

  private

  def broadcast_to_recipient
    ActionCable.server.broadcast(
      "notifications_user_#{recipient_id}",
      { count: recipient.notifications.unread.count }
    )
  end
end
