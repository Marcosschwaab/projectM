class TasksChannel < ApplicationCable::Channel
  def subscribed
    project = Project.find(params[:project_id])
    stream_from "tasks_project_#{project.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
