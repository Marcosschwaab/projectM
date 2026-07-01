class KeyResultsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization_and_cycle
  before_action :set_objective
  before_action :set_key_result, only: %i[edit update destroy]

  def edit
    authorize @key_result
  end

  def create
    @key_result = @objective.key_results.build(key_result_params)
    authorize @key_result
    if @key_result.save
      @key_result.update_progress!
      redirect_to [@organization, @cycle], notice: t("flash.key_result.added")
    else
      redirect_to [@organization, @cycle], alert: t("flash.key_result.create_failed")
    end
  end

  def update
    authorize @key_result
    if @key_result.update(key_result_params)
      @key_result.update_progress!
      redirect_to [@organization, @cycle], notice: t("flash.key_result.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @key_result
    @key_result.destroy!
    redirect_to [@organization, @cycle], notice: t("flash.key_result.deleted")
  end

  private

  def set_organization_and_cycle
    @organization = Organization.find(params[:organization_id])
    @cycle = @organization.okr_cycles.find(params[:okr_cycle_id])
  end

  def set_objective
    @objective = @cycle.objectives.find(params[:objective_id])
  end

  def set_key_result
    @key_result = @objective.key_results.find(params[:id])
    authorize @key_result
  end

  def key_result_params
    params.require(:key_result).permit(:title, :description, :target_value, :current_value, :unit)
  end
end
