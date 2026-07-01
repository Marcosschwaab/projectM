class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy move modal]

  def index
    @tasks = policy_scope(Task).where(project: @project).by_status

    @tasks = @tasks.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    @tasks = @tasks.where(priority: Task.priorities[params[:priority]]) if params[:priority].present?
    @tasks = @tasks.where(status: Task.statuses[params[:status]]) if params[:status].present?
    @tasks = @tasks.where("tasks.due_date >= ?", Date.parse(params[:due_date_from])) if params[:due_date_from].present?
    @tasks = @tasks.where("tasks.due_date <= ?", Date.parse(params[:due_date_to])) if params[:due_date_to].present?
    @tasks = @tasks.where("tasks.title ILIKE ?", "%#{params[:q]}%") if params[:q].present?
    if params[:tag_id].present?
      @tasks = @tasks.joins(:task_tags).where(task_tags: { tag_id: params[:tag_id] })
    end
  end

  def show
    authorize @task
    @comment = @task.comments.build
    @checklist_item = @task.checklist_items.build
  end

  def new
    @task = @project.tasks.build(task_params_for_new)
    authorize @task
  end

  def edit
    authorize @task
  end

  def create
    @task = @project.tasks.build(task_params)
    authorize @task

    if @task.save
      ActivityLog.create!(action: "created task #{@task.title}", trackable: @task, user: current_user, organization: @organization, project: @project)

      if @task.assignee && @task.assignee != current_user
        @task.assignee.notifications.create!(
          actor: current_user, action: "task_assigned", notifiable: @task, organization: @organization
        )
      end

      redirect_to [ @organization, @project, @task ], notice: t("flash.task.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @task
    prev_assignee = @task.assignee_id
    if @task.update(task_params)
      ActivityLog.create!(action: "updated task #{@task.title}", trackable: @task, user: current_user, organization: @organization, project: @project)
      if @task.assignee && @task.assignee != current_user && (!prev_assignee || prev_assignee != @task.assignee_id)
        @task.assignee.notifications.create!(
          actor: current_user, action: "task_assigned", notifiable: @task, organization: @organization
        )
      end
      redirect_to [ @organization, @project, @task ], notice: t("flash.task.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @task
    title = @task.title
    @task.destroy!
    ActivityLog.create!(action: "deleted task #{title}", trackable: @project, user: current_user, organization: @organization, project: @project)
    redirect_to organization_project_tasks_path(@organization, @project), notice: t("flash.task.destroyed")
  end

  def modal
    authorize @task
    @comment = @task.comments.build
    @checklist_item = @task.checklist_items.build
    render layout: false
  end

  def move
    authorize @task
    prev_status = @task.status
    if @task.update(status: params[:status], position: params[:position])
      if prev_status != @task.status
        ActivityLog.create!(action: "moved task #{@task.title} to #{@task.status}", trackable: @task, user: current_user, organization: @organization, project: @project)
        if @task.assignee && @task.assignee != current_user
          @task.assignee.notifications.create!(
            actor: current_user, action: "task_moved", notifiable: @task, organization: @organization
          )
        end
      end
      broadcast_task_move
      dispatch_webhook_for_move
      render json: { success: true }
    else
      render json: { success: false, errors: @task.errors }, status: :unprocessable_content
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
    @task = @project.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :assignee_id, :priority, :status, :due_date, tag_ids: [], files: [], dependency_ids: [])
  end

  def task_params_for_new
    params.fetch(:task, {}).permit(:title, :description, :assignee_id, :priority, :status, :due_date, tag_ids: [], files: [], dependency_ids: [])
  end

  def broadcast_task_move
    html = render_to_string(partial: "kanban/kanban_card", locals: { task: @task }, formats: [ :html ])
    ActionCable.server.broadcast(
      "tasks_project_#{@project.id}",
      { action: "move", task_id: @task.id, status: @task.status, html: html }
    )
  end

  def dispatch_webhook_for_move
    payload = {
      organization_id: @organization.id,
      event: "task.moved",
      data: {
        id: @task.id,
        title: @task.title,
        status: @task.status,
        previous_status: params[:status],
        project: @project.name
      },
      timestamp: Time.current.iso8601
    }
    @organization.webhooks.active.each do |webhook|
      next unless webhook.events.include?("task.moved")
      WebhookDeliveryJob.perform_later(webhook, "task.moved", payload)
    end
  end
end
