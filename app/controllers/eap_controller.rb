class EapController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project

  def show
    tasks = @project.tasks.includes(:assignee, :dependencies).to_a

    @eap_items = tasks.map do |t|
      {
        id: t.id,
        name: t.title,
        status: eap_status(t),
        assignee: t.assignee&.name,
        start_date: t.created_at.to_date,
        end_date: t.due_date,
        progress: t.progress.to_f,
        dependency_ids: t.dependency_ids
      }
    end

    @root_items = @eap_items.select { |i| i[:dependency_ids].empty? }
    @items_by_parent = @eap_items.each_with_object(Hash.new { |h, k| h[k] = [] }) do |item, hash|
      item[:dependency_ids].each { |dep_id| hash[dep_id] << item }
    end
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def eap_status(task)
    return "milestone" if task.status == "done" && task.progress.to_f >= 100
    return "milestone" if task.due_date.nil? && task.status == "done"
    return "overdue" if task.due_date.present? && task.due_date < Date.today && task.status != "done"
    return "at_risk" if task.due_date.present? && task.due_date <= Date.today + 3 && task.status != "done"
    return "suspended" if task.status == "backlog"
    "on_time"
  end
end
