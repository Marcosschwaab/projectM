# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  protected

  def organization
    if record.is_a?(Class)
      nil
    elsif record.respond_to?(:organization)
      record.organization
    elsif record.respond_to?(:project)
      record.project.organization
    end
  end

  def org_role
    user.org_role(organization) if organization
  end

  def super_admin?
    org_role == "super_admin"
  end

  def org_admin?
    org_role == "admin"
  end

  def org_admin_or_manager?
    %w[admin manager].include?(org_role)
  end

  def project_manager?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end
end
