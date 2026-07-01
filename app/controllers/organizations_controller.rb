class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization, only: %i[show edit update destroy]

  def index
    @organizations = policy_scope(Organization)
  end

  def show
    authorize @organization
  end

  def new
    @organization = Organization.new
    authorize @organization
  end

  def edit
    authorize @organization
  end

  def create
    @organization = Organization.new(organization_params)
    authorize @organization

    if @organization.save
      @organization.memberships.create!(user: current_user, role: :admin)
      redirect_to @organization, notice: t("flash.organization.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @organization
    if @organization.update(organization_params)
      redirect_to @organization, notice: t("flash.organization.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @organization
    @organization.destroy!
    redirect_to organizations_url, notice: t("flash.organization.destroyed")
  end

  private

  def set_organization
    @organization = Organization.find(params[:id])
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :allow_auto_join)
  end
end
