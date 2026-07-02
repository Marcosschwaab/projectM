class CustomFieldsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def index
    @custom_fields = policy_scope(CustomField).where(organization: @organization).order(:name)
    authorize @organization, :show?
  end

  def new
    @custom_field = @organization.custom_fields.build
    authorize @custom_field
  end

  def create
    @custom_field = @organization.custom_fields.build(custom_field_params)
    authorize @custom_field

    if @custom_field.save
      redirect_to organization_custom_fields_path(@organization), notice: t("flash.custom_field.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @custom_field = @organization.custom_fields.find(params[:id])
    authorize @custom_field
  end

  def update
    @custom_field = @organization.custom_fields.find(params[:id])
    authorize @custom_field

    if @custom_field.update(custom_field_params)
      redirect_to organization_custom_fields_path(@organization), notice: t("flash.custom_field.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @custom_field = @organization.custom_fields.find(params[:id])
    authorize @custom_field
    @custom_field.destroy!
    redirect_to organization_custom_fields_path(@organization), notice: t("flash.custom_field.destroyed")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def custom_field_params
    params.require(:custom_field).permit(:name, :field_type, :required, options: [])
  end
end
