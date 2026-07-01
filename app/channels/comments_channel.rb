class CommentsChannel < ApplicationCable::Channel
  def subscribed
    task = Task.find(params[:task_id])
    stream_from "comments_task_#{task.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
