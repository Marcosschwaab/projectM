class ProjectMatricesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_matrix, only: %i[show edit update destroy]

  def index
    @matrices = @project.project_matrices.order(:created_at)
  end

  def show
  end

  def new
    @matrix = @project.project_matrices.build
  end

  def edit
  end

  def create
    @matrix = @project.project_matrices.build(matrix_params)

    if @matrix.save
      redirect_to [@organization, @project, @matrix], notice: t("flash.matrix.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    @matrix.assign_attributes(matrix_params)
    sync_columns
    sync_rows
    sync_cells if @matrix.persisted?

    if @matrix.save
      redirect_to [@organization, @project, @matrix], notice: t("flash.matrix.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @matrix.destroy!
    redirect_to organization_project_matrices_path(@organization, @project), notice: t("flash.matrix.destroyed")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def set_matrix
    @matrix = @project.project_matrices.find(params[:id])
  end

  def matrix_params
    params.require(:project_matrix).permit(:name)
  end

  def sync_columns
    return unless params[:columns].is_a?(Array)

    kept_ids = []
    params[:columns].each_with_index do |col, idx|
      if col[:_destroy].to_s == "1" && col[:id].present?
        @matrix.matrix_columns.find_by(id: col[:id])&.destroy
      elsif col[:id].present?
        c = @matrix.matrix_columns.find_by(id: col[:id])
        c&.update(name: col[:name], position: idx)
        kept_ids << col[:id].to_i if c
      else
        c = @matrix.matrix_columns.create(name: col[:name], position: idx)
        kept_ids << c.id if c.persisted?
      end
    end
  end

  def sync_rows
    return unless params[:rows].is_a?(Array)

    kept_ids = []
    params[:rows].each_with_index do |row, idx|
      if row[:_destroy].to_s == "1" && row[:id].present?
        @matrix.matrix_rows.find_by(id: row[:id])&.destroy
      elsif row[:id].present?
        r = @matrix.matrix_rows.find_by(id: row[:id])
        r&.update(name: row[:name], position: idx)
        kept_ids << row[:id].to_i if r
      else
        r = @matrix.matrix_rows.create(name: row[:name], position: idx)
        kept_ids << r.id if r.persisted?
      end
    end
  end

  def sync_cells
    return unless params[:cells].is_a?(Hash)

    params[:cells].each do |row_id, columns|
      columns.each do |col_id, value|
        next unless row_id.present? && col_id.present?
        cell = @matrix.matrix_cells.find_or_initialize_by(matrix_column_id: col_id, matrix_row_id: row_id)
        cell.update(value: value)
      end
    end
  end
end
