class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: %i[ edit update destroy make_in_progress make_completed ]

  def new
    @task = @project.tasks.new
  end

  def edit
  end

  def create
    @task = @project.tasks.new(task_params)

    if @task.save
      redirect_to edit_project_path(@project), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @task.update(task_params)
      redirect_to edit_project_path(@project), notice: "Task was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @task.destroy!

    redirect_to edit_project_path(@project), notice: "Task was successfully destroyed.", status: :see_other
  end

  def make_in_progress
    @task.in_progress!

    respond_to do |format|
      format.turbo_stream { render :update_status }
      format.html { redirect_to edit_project_path(@project), status: :see_other }
    end
  end

  def make_completed
    @task.completed!

    respond_to do |format|
      format.turbo_stream { render :update_status }
      format.html { redirect_to edit_project_path(@project), status: :see_other }
    end
  end

  private
    def set_project
      @project = Project.find(params.expect(:project_id))
    end

    def set_task
      @task = @project.tasks.find(params.expect(:id))
    end

    def task_params
      params.require(:task).permit(:title, :status)
    end
end
