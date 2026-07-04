class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project, only: %i[show edit update destroy archive]

  def index
    @projects = policy_scope(Project).where(organization: @organization)
    @projects = if params[:status] == "archived"
      @projects.archived
    else
      @projects.active
    end
  end

  def show
    authorize @project
    now = Date.today

    @gantt_tasks = @project.tasks.includes(:dependencies).order(:created_at).to_a
    now = Date.today
    dates = @gantt_tasks.map { |t| [ t.created_at, t.due_date ] }
    @gantt_start = @project.start_date || dates.map { |c, _| c.to_date }.min || now
    @gantt_end = @project.end_date || dates.map { |_, d| d }.compact.max || now + 30

    @activity_logs = ActivityLog.for_project(@project).recent.includes(:user).page(params[:timeline_page]).per(10)

    task_index = @gantt_tasks.each_with_index.to_h { |t, i| [ t.id, i ] }
    @gantt_items = @gantt_tasks.map do |t|
      s = t.created_at.to_date
      e = t.due_date || s + 14
      deps = t.dependencies.filter_map { |d| task_index[d.id] }
      {
        name: t.title,
        assignee: t.assignee&.name,
        start: s.to_s,
        end: e.to_s,
        color: task_gantt_color(t),
        dependencies: deps
      }
    end
  end

  def new
    @project = @organization.projects.build
    authorize @project
  end

  def edit
    authorize @project
  end

  def create
    @project = @organization.projects.build(project_params.except(:project_member_ids, :project_manager_ids))
    authorize @project
    sync_project_members(@project)

    if @project.save
      ActivityLog.create!(action: "created project #{@project.name}", trackable: @project, user: current_user, organization: @organization, project: @project)
      redirect_to [ @organization, @project ], notice: t("flash.project.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @project
    @project.assign_attributes(project_params.except(:project_member_ids, :project_manager_ids))
    sync_project_members(@project)
    if @project.save
      ActivityLog.create!(action: "updated project #{@project.name}", trackable: @project, user: current_user, organization: @organization, project: @project)
      redirect_to [ @organization, @project ], notice: t("flash.project.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @project
    @project.destroy!
      redirect_to organization_projects_path(@organization), notice: t("flash.project.destroyed")
  end

  def archive
    authorize @project
    @project.update!(archived: !@project.archived)
    action = @project.archived? ? "archived project #{@project.name}" : "restored project #{@project.name}"
    ActivityLog.create!(action: action, trackable: @project, user: current_user, organization: @organization, project: @project)
    redirect_to organization_projects_path(@organization), notice: @project.archived? ? t("flash.project.archived") : t("flash.project.restored")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :priority, :status, :assignee_id, :color, :icon, :start_date, :end_date, :category, :sponsor_id, :manager_id, :approval_all_team, :proposal_investment_estimated, :project_investment_estimated, :budget_estimated, :budget_actual, :return_estimated, :return_actual, approval_roles: [], project_member_ids: [], project_manager_ids: [], custom_field_values_attributes: [:id, :custom_field_id, :value])
  end

  def sync_project_members(project)
    member_ids = (params.dig(:project, :project_member_ids) || []).reject(&:blank?).map(&:to_i)
    manager_ids = (params.dig(:project, :project_manager_ids) || []).reject(&:blank?).map(&:to_i)
    all_ids = member_ids + manager_ids

    existing = project.project_members.includes(:user).index_by(&:user_id)

    to_remove = existing.keys - all_ids
    to_add_members = member_ids - existing.keys
    to_add_managers = manager_ids - existing.keys

    existing.each do |uid, pm|
      next if to_remove.include?(uid)
      if manager_ids.include?(uid) && pm.member?
        pm.update_column(:role, "manager")
      elsif member_ids.include?(uid) && pm.manager?
        pm.update_column(:role, "member")
      end
    end

    to_add_members.each { |uid| project.project_members.build(user_id: uid, role: "member") }
    to_add_managers.each { |uid| project.project_members.build(user_id: uid, role: "manager") }

    project.project_members.where(user_id: to_remove).destroy_all
  end

  def status_gantt_color(status)
    case status.to_s
    when "backlog" then "bg-gray-400"
    when "in_progress" then "bg-blue-500"
    when "in_review" then "bg-purple-500"
    when "todo" then "bg-yellow-500"
    else "bg-gray-400"
    end
  end
end
