class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ edit update destroy ]
  before_action :set_tasks, only: %i[ edit update ]

  def index
    @projects = Project.all
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to edit_project_path(@project), notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @project.update(project_params)
      redirect_to edit_project_path(@project), notice: "Project was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @project.destroy!

    redirect_to projects_path, notice: "Project was successfully destroyed.", status: :see_other
  end

  private
    def set_project
      @project = Project.find(params.expect(:id))
    end

    def set_tasks
      @tasks = @project.tasks
    end

    def project_params
      params.require(:project).permit(:name)
    end
end
