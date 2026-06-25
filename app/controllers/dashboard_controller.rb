class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @organization = current_user.organizations.first
    return redirect_to new_organization_path, alert: "Create an organization to get started." unless @organization

    @projects = policy_scope(Project).where(organization: @organization).active.includes(:assignee)
    @tasks = policy_scope(Task).where(project_id: @projects.pluck(:id)).includes(:assignee, :project)

    @active_projects_count = @projects.count
    @completed_projects_count = @projects.where(status: :completed).count
    @open_tasks_count = @tasks.where.not(status: :done).count
    @overdue_tasks = @tasks.where("due_date < ? AND status != ?", Date.today, :done)
    @upcoming_tasks = @tasks.where(due_date: Date.today..7.days.from_now).where.not(status: :done)
    @recent_activity = ActivityLog.where(organization: @organization).order(created_at: :desc).limit(10)
  end
end
