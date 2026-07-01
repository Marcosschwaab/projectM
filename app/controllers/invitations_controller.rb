class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def index
    authorize @organization, :manage_members?
    @invitations = @organization.invitations.pending
  end

  def new
    authorize @organization, :manage_members?
    @invitation = @organization.invitations.build
  end

  def create
    authorize @organization, :manage_members?
    @invitation = @organization.invitations.build(invitation_params)
    @invitation.user = current_user
    @invitation.role = permitted_role

    if @invitation.save
      redirect_to organization_invitations_path(@organization), notice: t("flash.invitation.sent")
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def invitation_params
    params.require(:invitation).permit(:email)
  end

  def permitted_role
    desired = params.dig(:invitation, :role)&.to_sym
    role = current_user.role_in(@organization)

    if role == "admin"
      desired
    elsif role == "manager" && desired.in?(%i[member manager])
      desired
    else
      :member
    end
  end
end
