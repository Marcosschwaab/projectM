class RisksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_risk, only: %i[show edit update destroy]

  def index
    @risks = policy_scope(Risk).where(project: @project).by_severity
    @risks = @risks.where(status: params[:status]) if params[:status].present?
    @risks = @risks.where(owner_id: params[:owner_id]) if params[:owner_id].present?
    @matrix_risks = @risks.group_by(&:severity_label)
  end

  def show
    authorize @risk
  end

  def new
    @risk = @project.risks.build
    authorize @risk
  end

  def edit
    authorize @risk
  end

  def create
    @risk = @project.risks.build(risk_params)
    authorize @risk
    if @risk.save
      ActivityLog.create!(action: "created risk #{@risk.name}", trackable: @risk, user: current_user, organization: @organization, project: @project)
      redirect_to organization_project_risks_path(@organization, @project), notice: t("flash.risk.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @risk
    if @risk.update(risk_params)
      ActivityLog.create!(action: "updated risk #{@risk.name}", trackable: @risk, user: current_user, organization: @organization, project: @project)
      redirect_to organization_project_risks_path(@organization, @project), notice: t("flash.risk.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @risk
    name = @risk.name
    @risk.destroy!
    ActivityLog.create!(action: "deleted risk #{name}", trackable: @project, user: current_user, organization: @organization, project: @project)
    redirect_to organization_project_risks_path(@organization, @project), notice: t("flash.risk.destroyed")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def set_risk
    @risk = @project.risks.find(params[:id])
    authorize @risk
  end

  def risk_params
    params.require(:risk).permit(:name, :description, :probability, :impact, :status, :mitigation_plan, :contingency_plan, :owner_id)
  end
end