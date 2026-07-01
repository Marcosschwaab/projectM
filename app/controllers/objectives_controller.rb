class ObjectivesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_cycle
  before_action :set_objective, only: %i[edit update destroy]

  def edit
    authorize @objective
  end

  def create
    @objective = @cycle.objectives.build(objective_params)
    authorize @objective
    if @objective.save
      redirect_to [@organization, @cycle], notice: t("flash.objective.added")
    else
      redirect_to [@organization, @cycle], alert: t("flash.objective.create_failed")
    end
  end

  def update
    authorize @objective
    if @objective.update(objective_params)
      @objective.update_progress!
      redirect_to [@organization, @cycle], notice: t("flash.objective.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @objective
    @objective.destroy!
    redirect_to [@organization, @cycle], notice: t("flash.objective.deleted")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_cycle
    @cycle = @organization.okr_cycles.find(params[:okr_cycle_id])
  end

  def set_objective
    @objective = @cycle.objectives.find(params[:id])
    authorize @objective
  end

  def objective_params
    params.require(:objective).permit(:title, :description, :owner_id, :project_id)
  end
end
