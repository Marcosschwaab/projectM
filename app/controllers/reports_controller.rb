class ReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def show
    @projects = policy_scope(Project).where(organization: @organization).includes(:tasks, :assignee)
    @tasks = policy_scope(Task).where(project_id: @projects.pluck(:id))
    @okr_cycles = @organization.okr_cycles

    @total_projects = @projects.count
    @completed_projects = @projects.where(status: :completed).count
    @total_tasks = @tasks.count
    @completed_tasks = @tasks.where(status: :done).count
    @overdue_tasks = @tasks.where("due_date < ? AND status != ?", Date.today, :done).count
    @productivity = @total_tasks > 0 ? ((@completed_tasks.to_f / @total_tasks) * 100).round(1) : 0
  end

  private

  def set_organization
    @organization = current_user.organizations.first
    redirect_to new_organization_path, alert: "Create an organization first." unless @organization
  end
end
