class TagsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def index
    @tags = policy_scope(Tag).where(organization: @organization).order(:name)
    authorize @organization, :show?
  end

  def new
    @tag = @organization.tags.build
    authorize @tag
  end

  def create
    @tag = @organization.tags.build(tag_params)
    authorize @tag

    if @tag.save
      redirect_to organization_tags_path(@organization), notice: t("flash.tag.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @tag = @organization.tags.find(params[:id])
    authorize @tag
  end

  def update
    @tag = @organization.tags.find(params[:id])
    authorize @tag

    if @tag.update(tag_params)
      redirect_to organization_tags_path(@organization), notice: t("flash.tag.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @tag = @organization.tags.find(params[:id])
    authorize @tag
    @tag.destroy!
    redirect_to organization_tags_path(@organization), notice: t("flash.tag.destroyed")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end
