class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent.includes(:actor, :notifiable)
    @unread = @notifications.unread
    @read = @notifications.where(read: true).limit(30)
  end

  def mark_read
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_read!
    head :ok
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read: true, read_at: Time.current)
    redirect_back fallback_location: notifications_path
  end
end
