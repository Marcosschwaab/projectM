class StrategicCanvasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project

  def show
    @canvas = @project.strategic_canvas || @project.build_strategic_canvas
    authorize @canvas
  end

  def update
    @canvas = @project.strategic_canvas || @project.build_strategic_canvas
    authorize @canvas

    if @canvas.update(canvas_params)
      redirect_to [ @organization, @project, @canvas ], notice: "Canvas updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def canvas_params
    params.require(:strategic_canvas).permit(:problem, :goal, :value_proposition, :stakeholders, :team, :metrics, :risks, :resources, :roadmap, :next_steps)
  end
end
