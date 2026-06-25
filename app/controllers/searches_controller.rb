class SearchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization

  def show
    @query = params[:q]
    return if @query.blank?

    @projects = policy_scope(Project).where(organization: @organization).where("name ILIKE ?", "%#{@query}%")
    @tasks = policy_scope(Task).joins(:project).where(projects: { organization_id: @organization }).where("tasks.title ILIKE ?", "%#{@query}%")
    @users = @organization.members.where("name ILIKE ? OR email ILIKE ?", "%#{@query}%", "%#{@query}%")

    @results_count = @projects.count + @tasks.count + @users.count
  end

  private

  def set_organization
    @organization = current_user.organizations.first
  end
end
