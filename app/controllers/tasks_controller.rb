class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: %i[ edit update destroy make_in_progress make_completed ]

  # GET /projects/:project_id/tasks/new
  def new
    @task = @project.tasks.new
  end

  # GET /projects/:project_id/tasks/1/edit
  def edit
  end

  # POST /projects/:project_id/tasks
  def create
    @task = @project.tasks.new(task_params)

    if @task.save
      redirect_to edit_project_path(@project), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /projects/:project_id/tasks/1
  def update
    if @task.update(task_params)
      redirect_to edit_project_path(@project), notice: "Task was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /projects/:project_id/tasks/1
  def destroy
    @task.destroy!

    redirect_to edit_project_path(@project), notice: "Task was successfully destroyed.", status: :see_other
  end

  # PATCH /projects/:project_id/tasks/1/make_in_progress
  def make_in_progress
    @task.in_progress!

    respond_to do |format|
      format.turbo_stream { render :update_status }
      format.html { redirect_to edit_project_path(@project) }
    end
  end

  # PATCH /projects/:project_id/tasks/1/make_completed
  def make_completed
    @task.completed!

    respond_to do |format|
      format.turbo_stream { render :update_status }
      format.html { redirect_to edit_project_path(@project) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params.expect(:project_id))
    end

    def set_task
      @task = @project.tasks.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def task_params
      params.expect(task: [ :title, :status ])
    end
end
