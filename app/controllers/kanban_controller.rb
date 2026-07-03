class KanbanController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project

  def show
    authorize @project, :show?
    @columns = @project.kanban_columns.ordered
    @tasks = policy_scope(Task)
      .where(project: @project)
      .includes(:assignee, :checklist_items)
      .by_status

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
