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
    @invitation.role ||= :member

    if @invitation.save
      redirect_to organization_invitations_path(@organization), notice: "Invitation sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end
