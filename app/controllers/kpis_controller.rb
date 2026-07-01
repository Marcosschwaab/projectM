class KpisController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_kpi, only: %i[show edit update destroy]

  def index
    @kpis = policy_scope(@organization.kpis).includes(:project, :owner).order(:category, :name)
    @org_kpis = @kpis.org_wide
    @project_kpis = @kpis.where.not(project_id: nil)
    @categories = @kpis.group_by(&:category)
  end

  def show
  end

  def new
    @kpi = @organization.kpis.build
    authorize @kpi
  end

  def create
    @kpi = @organization.kpis.build(kpi_params)
    authorize @kpi
    if @kpi.save
      redirect_to organization_kpis_path(@organization), notice: t("flash.kpi.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @kpi
  end

  def update
    authorize @kpi
    prev_value = @kpi.current_value
    if @kpi.update(kpi_params)
      if prev_value != @kpi.current_value
        @kpi.metadata["previous_value"] = prev_value.to_s
        @kpi.save
      end
      redirect_to organization_kpis_path(@organization), notice: t("flash.kpi.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @kpi
    @kpi.destroy!
    redirect_to organization_kpis_path(@organization), notice: t("flash.kpi.deleted")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_kpi
    @kpi = @organization.kpis.find(params[:id])
    authorize @kpi
  end

  def kpi_params
    params.require(:kpi).permit(:name, :description, :target_value, :current_value, :unit, :category, :frequency, :project_id, :owner_id)
  end
end
