class KanbanColumnsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project

  def index
    authorize @project, :show?
    @columns = @project.kanban_columns.ordered
  end

  def create
    authorize @project, :update?
    @column = @project.kanban_columns.build(column_params)
    @column.position = (@project.kanban_columns.maximum(:position) || -1) + 1

    if @column.save
      redirect_to organization_project_kanban_columns_path(@organization, @project), notice: t("flash.kanban_column.created")
    else
      @columns = @project.kanban_columns.ordered
      render :index, status: :unprocessable_content
    end
  end

  def update
    @column = @project.kanban_columns.find(params[:id])
    authorize @project, :update?

    if @column.update(column_params)
      redirect_to organization_project_kanban_columns_path(@organization, @project), notice: t("flash.kanban_column.updated")
    else
      @columns = @project.kanban_columns.ordered
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    @column = @project.kanban_columns.find(params[:id])
    authorize @project, :update?
    @column.destroy!
    redirect_to organization_project_kanban_columns_path(@organization, @project), notice: t("flash.kanban_column.destroyed")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def column_params
    params.require(:kanban_column).permit(:label, :status, :color)
  end
end
