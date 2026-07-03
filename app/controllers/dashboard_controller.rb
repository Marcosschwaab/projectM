class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    @organization = current_user.organizations.first
    return redirect_to new_organization_path, alert: t("flash.create_organization_first") unless @organization

    @widgets = policy_scope(DashboardWidget).visible.ordered
    @widgets = DashboardWidget.defaults_for(current_user) if @widgets.empty?

    load_dashboard_data
  end

  private

  def load_dashboard_data
    @projects = policy_scope(Project).where(organization: @organization).includes(:assignee)
    @tasks = policy_scope(Task).where(project_id: @projects.pluck(:id)).includes(:assignee, :project)

    @active_projects_count = @projects.active.count
    @completed_projects_count = @projects.where(status: :completed).count
    @open_tasks_count = @tasks.where.not(status: :done).count
    @overdue_tasks = @tasks.where("tasks.due_date < ?", Date.today).where.not(status: :done)
    @my_tasks = @tasks.where(assignee_id: current_user.id)
    @upcoming_tasks = @tasks.where(due_date: Date.today..7.days.from_now).where.not(status: :done)
    @recent_activity = ActivityLog.where(organization: @organization).includes(:user).order(created_at: :desc).limit(8)

    @status_distribution = @projects.group(:status).count
    @task_status_distribution = @tasks.group(:status).count
    @priority_distribution = @tasks.group(:priority).count
    @tasks_by_project = @projects.left_joins(:tasks).group("projects.id", "projects.name").count("tasks.id")
    @completion_rate = @tasks.count > 0 ? ((@tasks.where(status: :done).count.to_f / @tasks.count) * 100).round(0) : 0
    @members_count = @organization.members.count

    @active_cycle = @organization.okr_cycles.find_by(status: :active)
    @okr_progress = @active_cycle&.overall_progress || 0
    @kpis = policy_scope(@organization.kpis).limit(6)
    @kpi_achieved = @kpis.count { |k| k.calculate_progress >= 100 }
    @kpi_total = @kpis.size

    @burndown_data = (0..29).map do |i|
      day = i.days.ago.to_date
      created = Task.where(project_id: @projects.pluck(:id)).where("DATE(tasks.created_at) = ?", day).count
      done = Task.where(project_id: @projects.pluck(:id)).where(status: :done).where("DATE(tasks.updated_at) = ?", day).count
      { date: day, created: created, done: done, remaining: @tasks.where("DATE(tasks.created_at) <= ?", day).where.not(status: :done).count }
    end.reverse

    @workload_data = User.where(id: @tasks.select(:assignee_id).distinct).map do |user|
      { name: user.name, total: @tasks.where(assignee_id: user.id).count, done: @tasks.where(assignee_id: user.id, status: :done).count }
    end.sort_by { |w| -w[:total] }

    @weekly_velocity = (0..7).map do |i|
      week_start = (i.weeks.ago).beginning_of_week
      week_end = week_start.end_of_week
      done = Task.where(project_id: @projects.pluck(:id)).where(status: :done).where(updated_at: week_start..week_end).count
      total_created = Task.where(project_id: @projects.pluck(:id)).where(created_at: week_start..week_end).count
      { week: week_start.strftime("%b %d"), done: done, created: total_created }
    end.reverse

    @gantt_projects = @projects.active.order(:start_date)
    now = Date.today
    @gantt_start = @gantt_projects.map { |p| p.start_date || p.created_at.to_date }.min || now
    @gantt_end = @gantt_projects.map { |p| p.end_date || p.created_at.to_date + 90 }.max || now + 90
    @gantt_items = @gantt_projects.map do |p|
      s = p.start_date || p.created_at.to_date
      e = p.end_date || s + 90
      {
        name: p.name,
        assignee: p.assignee&.name,
        start: s.to_s,
        end: e.to_s,
        color: project_gantt_color(p),
        dependencies: []
      }
    end
  end

  def project_gantt_color(status)
    case status.to_s
    when "on_track" then "bg-green-500"
    when "at_risk" then "bg-red-500"
    when "behind" then "bg-orange-500"
    when "on_hold" then "bg-gray-500"
    when "completed" then "bg-blue-500"
    else "bg-indigo-500"
    end
  end
end
