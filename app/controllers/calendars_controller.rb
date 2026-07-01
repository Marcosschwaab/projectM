class CalendarsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def show
    @today = Date.current
    @year = (params[:year] || @today.year).to_i
    @month = (params[:month] || @today.month).to_i
    @start_date = Date.new(@year, @month, 1)
    @end_date = @start_date.end_of_month

    @tasks = policy_scope(Task)
      .where(project: @organization.projects)
      .where(due_date: @start_date..@end_date)
      .includes(:project, :assignee)
      .order(:due_date, :position)

    @tasks_by_date = @tasks.group_by(&:due_date)
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end
end
