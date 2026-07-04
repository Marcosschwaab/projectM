class ProgramsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_program, only: %i[show edit update destroy]

  def index
    @programs = policy_scope(Program).where(organization: @organization).order(:name)
  end

  def show
    authorize @program
    @projects = @program.projects.includes(:assignee).active.order(:name)
    @rollup = rollup_data
  end

  def new
    @program = @organization.programs.build
    authorize @program
  end

  def edit
    authorize @program
  end

  def create
    @program = @organization.programs.build(program_params)
    authorize @program

    if @program.save
      redirect_to organization_program_path(@organization, @program), notice: t("flash.program.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @program

    if @program.update(program_params)
      redirect_to organization_program_path(@organization, @program), notice: t("flash.program.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @program
    @program.destroy!
    redirect_to organization_programs_path(@organization), notice: t("flash.program.deleted")
  end

  private

  def set_organization
    @organization = current_user.organizations.find(params[:organization_id])
  end

  def set_program
    @program = @organization.programs.find(params[:id])
  end

  def program_params
    params.require(:program).permit(:name, :description, :color, :icon, :status, :start_date, :end_date, :budget)
  end

  def rollup_data
    projects = @program.projects.active
    {
      projects_count: projects.size,
      progress: @program.progress,
      tasks_count: @program.tasks_count,
      tasks_done_count: @program.tasks_done_count,
      total_budget_estimated: @program.total_budget_estimated,
      total_budget_actual: @program.total_budget_actual,
      objectives_count: @program.objectives_count,
      key_results_count: @program.key_results_count,
      risks_count: @program.risks_count,
      risks_open_count: @program.risks_open_count
    }
  end
end
