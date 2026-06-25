class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project, only: %i[show edit update destroy archive]

  def index
    @projects = policy_scope(Project).where(organization: @organization).active
  end

  def show
    authorize @project
  end

  def new
    @project = @organization.projects.build
    authorize @project
  end

  def edit
    authorize @project
  end

  def create
    @project = @organization.projects.build(project_params)
    authorize @project

    if @project.save
      redirect_to [ @organization, @project ], notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @project
    if @project.update(project_params)
      redirect_to [ @organization, @project ], notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy!
    redirect_to organization_projects_path(@organization), notice: "Project was successfully destroyed."
  end

  def archive
    authorize @project
    @project.update!(archived: !@project.archived)
    redirect_to organization_projects_path(@organization), notice: @project.archived? ? "Project archived." : "Project restored."
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :priority, :status, :assignee_id, :color, :icon, :start_date, :end_date)
  end
end
