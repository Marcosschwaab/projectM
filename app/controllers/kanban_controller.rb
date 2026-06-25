class KanbanController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project

  def show
    authorize @project, :show?
    @tasks = policy_scope(Task).where(project: @project).includes(:assignee)
    @grouped_tasks = @tasks.group_by(&:status)
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end
end
