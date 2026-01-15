class TasksController < ApplicationController
    def index
      render json: Task.all
    end
  
    def show
      render json: Task.find(params[:id])
    end
  
    def create
      task = Task.create!(task_params)
      render json: task, status: :created
    end
  
    def update
      task = Task.find(params[:id])
      task.update!(task_params)
      render json: task
    end
  
    def destroy
      Task.find(params[:id]).destroy
      head :no_content
    end
  
    private
  
    def task_params
      params.require(:task).permit(
        :title,
        :description,
        :status,
        :priority,
        :due_date,
        :user_id
      )
    end
  end
  