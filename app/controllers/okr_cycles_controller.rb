class OkrCyclesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_cycle, only: %i[show edit update destroy]

  def index
    @cycles = policy_scope(@organization.okr_cycles).order(start_date: :desc)
    @active_cycle = @cycles.find_by(status: :active)
  end

  def show
    @objectives = @cycle.objectives.includes(:owner, :project, :key_results).order(:created_at)
  end

  def new
    @cycle = @organization.okr_cycles.build
    authorize @cycle
  end

  def create
    @cycle = @organization.okr_cycles.build(cycle_params)
    authorize @cycle
    if @cycle.save
      redirect_to [ @organization, @cycle ], notice: t("flash.okr_cycle.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @cycle
  end

  def update
    authorize @cycle
    if @cycle.update(cycle_params)
      redirect_to [ @organization, @cycle ], notice: t("flash.okr_cycle.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @cycle
    @cycle.destroy!
    redirect_to organization_okr_cycles_path(@organization), notice: t("flash.okr_cycle.deleted")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_cycle
    @cycle = @organization.okr_cycles.find(params[:id])
    authorize @cycle
  end

  def cycle_params
    params.require(:okr_cycle).permit(:title, :start_date, :end_date, :status)
  end
end
