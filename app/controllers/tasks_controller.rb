class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_task, only: %i[show edit update destroy move]

  def index
    authorize Task
    @tasks = policy_scope(Task).where(project: @project).by_status
  end

  def show
    authorize @task
    @comment = @task.comments.build
    @checklist_item = @task.checklist_items.build
  end

  def new
    @task = @project.tasks.build
    authorize @task
  end

  def edit
    authorize @task
  end

  def create
    @task = @project.tasks.build(task_params)
    authorize @task

    if @task.save
      redirect_to [ @organization, @project, @task ], notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @task
    if @task.update(task_params)
      redirect_to [ @organization, @project, @task ], notice: "Task was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @task
    @task.destroy!
    redirect_to organization_project_tasks_path(@organization, @project), notice: "Task was successfully destroyed."
  end

  def move
    authorize @task
    if @task.update(status: params[:status], position: params[:position])
      render json: { success: true }
    else
      render json: { success: false, errors: @task.errors }, status: :unprocessable_entity
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
    params.require(:task).permit(:title, :description, :assignee_id, :priority, :status, :due_date)
  end
end
