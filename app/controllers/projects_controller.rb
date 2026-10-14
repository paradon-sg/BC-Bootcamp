class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ edit update destroy ]
  before_action :set_tasks, only: %i[ edit update ]

  # GET /projects
  def index
    @projects = Project.all
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to edit_project_path(@project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to edit_project_path(@project), notice: "Project was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy!

    redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params.expect(:id))
    end

    def set_tasks
      @tasks = @project.tasks
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.expect(project: [ :name ])
    end
end
