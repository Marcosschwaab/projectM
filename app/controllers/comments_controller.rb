class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_task

  def destroy
    @comment = @task.comments.find(params[:id])
    authorize @comment

    @comment.destroy!
    redirect_to [@organization, @project, @task], notice: t("flash.comment.deleted")
  end

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      ActivityLog.create!(action: "commented on task #{@task.title}", trackable: @task, user: current_user, organization: @organization, project: @project)
      if @task.assignee && @task.assignee != current_user
        @task.assignee.notifications.create!(
          actor: current_user, action: "task_commented", notifiable: @task, organization: @organization
        )
      end
      broadcast_comment
      redirect_to [ @organization, @project, @task ], notice: t("flash.comment.added")
    else
      redirect_to [ @organization, @project, @task ], alert: t("flash.comment.create_failed")
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def comment_params
    params.require(:comment).permit(:content, files: [])
  end

  def broadcast_comment
    html = render_to_string(partial: "comments/comment", locals: { comment: @comment }, formats: [ :html ])
    ActionCable.server.broadcast(
      "comments_task_#{@task.id}",
      { html: html }
    )
  end
end
