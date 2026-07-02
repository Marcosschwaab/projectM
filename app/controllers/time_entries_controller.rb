class TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_organization
  before_action :set_project
  before_action :set_task

  def start
    @time_entry = @task.time_entries.build(
      user: current_user,
      started_at: Time.current
    )
    authorize @time_entry

    if @time_entry.save
      redirect_to [@organization, @project, @task], notice: t("flash.time_entry.started")
    else
      redirect_to [@organization, @project, @task], alert: t("flash.time_entry.start_failed")
    end
  end

  def stop
    @time_entry = @task.time_entries.running.for_user(current_user).last
    authorize @time_entry

    @time_entry.stop!
    redirect_to [@organization, @project, @task], notice: t("flash.time_entry.stopped", duration: @time_entry.formatted_duration)
  end

  def create
    @time_entry = @task.time_entries.build(time_entry_params)
    @time_entry.user = current_user
    authorize @time_entry

    if @time_entry.save
      redirect_to [@organization, @project, @task], notice: t("flash.time_entry.created")
    else
      redirect_to [@organization, @project, @task], alert: t("flash.time_entry.create_failed")
    end
  end

  def update
    @time_entry = @task.time_entries.find(params[:id])
    authorize @time_entry

    if @time_entry.update(time_entry_params)
      redirect_to [@organization, @project, @task], notice: t("flash.time_entry.updated")
    else
      redirect_to [@organization, @project, @task], alert: t("flash.time_entry.update_failed")
    end
  end

  def destroy
    @time_entry = @task.time_entries.find(params[:id])
    authorize @time_entry

    @time_entry.destroy!
    redirect_to [@organization, @project, @task], notice: t("flash.time_entry.deleted")
  end

  private

  def set_organization
    @organization = Organization.find(params[:organization_id])
  end

  def set_project
    @project = @organization.projects.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:task_id])
  end

  def time_entry_params
    params.require(:time_entry).permit(:started_at, :ended_at, :duration, :description)
  end
end
