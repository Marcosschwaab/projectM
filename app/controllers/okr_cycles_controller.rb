class OkrCyclesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def index
    @cycles = @organization.okr_cycles.order(created_at: :desc)
  end

  def show
    @cycle = @organization.okr_cycles.find(params[:id])
    authorize @cycle
  end

  def new
    @cycle = @organization.okr_cycles.build
    authorize @cycle
  end

  def create
    @cycle = @organization.okr_cycles.build(okr_cycle_params)
    authorize @cycle

    if @cycle.save
      redirect_to [ @organization, @cycle ], notice: "OKR cycle created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def okr_cycle_params
    params.require(:okr_cycle).permit(:title, :start_date, :end_date, :status)
  end
end
