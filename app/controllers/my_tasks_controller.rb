class MyTasksController < ApplicationController
  before_action :authenticate_user!

  def show
    @tasks = policy_scope(Task).where(assignee: current_user).includes(:project, :assignee, :tags).order(created_at: :desc)

    @tasks = @tasks.where(priority: Task.priorities[params[:priority]]) if params[:priority].present?
    @tasks = @tasks.where(status: Task.statuses[params[:status]]) if params[:status].present?
    @tasks = @tasks.where(project_id: params[:project_id]) if params[:project_id].present?
    @tasks = @tasks.where("tasks.due_date >= ?", Date.parse(params[:due_date_from])) if params[:due_date_from].present?
    @tasks = @tasks.where("tasks.due_date <= ?", Date.parse(params[:due_date_to])) if params[:due_date_to].present?
    @tasks = @tasks.where("tasks.title ILIKE ?", "%#{params[:q]}%") if params[:q].present?

    @projects = policy_scope(Project).where(id: @tasks.select(:project_id)).distinct
    @overdue_count = @tasks.where("tasks.due_date < ?", Date.today).where.not(status: :done).count
    @done_count = @tasks.where(status: :done).count
    @total_count = @tasks.count
  end
end
