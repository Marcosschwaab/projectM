class WebhooksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_webhook, only: %i[show edit update destroy]

  def index
    @webhooks = policy_scope(Webhook).where(organization: @organization).order(:name)
    authorize @organization, :show?
  end

  def new
    @webhook = @organization.webhooks.build
    authorize @webhook
  end

  def create
    @webhook = @organization.webhooks.build(webhook_params)
    authorize @webhook

    if @webhook.save
      redirect_to organization_webhooks_path(@organization), notice: t("flash.webhook.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    authorize @webhook
  end

  def edit
    authorize @webhook
  end

  def update
    authorize @webhook

    if @webhook.update(webhook_params)
      redirect_to organization_webhooks_path(@organization), notice: t("flash.webhook.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @webhook
    @webhook.destroy!
    redirect_to organization_webhooks_path(@organization), notice: t("flash.webhook.destroyed")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_webhook
    @webhook = @organization.webhooks.find(params[:id])
  end

  def webhook_params
    params.require(:webhook).permit(:name, :url, :active, events: [])
  end
end
