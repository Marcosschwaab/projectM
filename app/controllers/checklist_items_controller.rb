class ChecklistItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_task

  def create
    @checklist_item = @task.checklist_items.build(checklist_item_params)
    authorize @checklist_item

    if @checklist_item.save
      redirect_to [ @organization, @project, @task ], notice: "Checklist item added."
    else
      redirect_to [ @organization, @project, @task ], alert: "Checklist item could not be created."
    end
  end

  def update
    @checklist_item = @task.checklist_items.find(params[:id])
    authorize @checklist_item
    @checklist_item.update(checklist_item_params)
    redirect_to [ @organization, @project, @task ]
  end

  def destroy
    @checklist_item = @task.checklist_items.find(params[:id])
    authorize @checklist_item
    @checklist_item.destroy!
    redirect_to [ @organization, @project, @task ], notice: "Checklist item removed."
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
