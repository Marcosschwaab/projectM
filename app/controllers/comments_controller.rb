class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_task

  def create
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user
    authorize @comment

    if @comment.save
      redirect_to [ @organization, @project, @task ], notice: "Comment added."
    else
      redirect_to [ @organization, @project, @task ], alert: "Comment could not be created."
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
    params.require(:comment).permit(:content)
  end
end
