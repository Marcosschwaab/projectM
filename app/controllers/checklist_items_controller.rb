class ChecklistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_task

  def create
    @checklist_item = @task.checklist_items.build(checklist_item_params)
    authorize @checklist_item

    if @checklist_item.save
      ActivityLog.create!(action: "added checklist item to task #{@task.title}", trackable: @task, user: current_user, organization: @organization, project: @project)
      redirect_to [ @organization, @project, @task ], notice: t("flash.checklist_item.added")
    else
      redirect_to [ @organization, @project, @task ], alert: t("flash.checklist_item.create_failed")
    end
  end

  def update
    @checklist_item = @task.checklist_items.find(params[:id])
    authorize @checklist_item
    @checklist_item.update(checklist_item_params)
    status = @checklist_item.completed? ? "completed" : "uncompleted"
    ActivityLog.create!(action: "#{status} checklist item in task #{@task.title}", trackable: @task, user: current_user, organization: @organization, project: @project)
    redirect_to [ @organization, @project, @task ]
  end

  def destroy
    @checklist_item = @task.checklist_items.find(params[:id])
    authorize @checklist_item
    content = @checklist_item.content
    @checklist_item.destroy!
    ActivityLog.create!(action: "removed checklist item from task #{@task.title}", trackable: @task, user: current_user, organization: @organization, project: @project)
    redirect_to [ @organization, @project, @task ], notice: t("flash.checklist_item.removed")
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

  def checklist_item_params
    params.require(:checklist_item).permit(:content, :completed, :position)
  end
end
