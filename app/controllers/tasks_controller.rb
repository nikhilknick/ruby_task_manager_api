class TasksController < ApplicationController
  before_action :authenticate_request
  before_action :set_task, only: [:show, :update, :destroy]

  SORTABLE_FIELDS = %w[created_at due_date priority].freeze

  def index
    tasks = current_user.tasks
                         .by_status(params[:status])
                         .by_priority(params[:priority])
                         .search(params[:q])
                         .order(sort_column => sort_order)
                         .page(params[:page])
                         .per(params[:per])

    render json: {
      data: ActiveModelSerializers::SerializableResource.new(tasks),
      meta: pagination_meta(tasks)
    }, status: :ok
  end

  def show
    render json: @task
  end

  def create
    task = current_user.tasks.build(task_params)

    if task.save
      TaskNotificationJob.perform_later(task.id, :created)
      render json: task.reload, status: :created
    else
      render json: task.errors, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      if @task.saved_change_to_status? && @task.completed?
        TaskNotificationJob.perform_later(@task.id, :completed)
      end

      render json: @task.reload
    else
      render json: @task.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    head :no_content
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Not Found" }, status: :not_found
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :status,
      :priority,
      :due_date
    )
  end

  def sort_column
    SORTABLE_FIELDS.include?(params[:sort_by]) ? params[:sort_by] : "created_at"
  end

  def sort_order
    params[:order] == "asc" ? :asc : :desc
  end

  def pagination_meta(records)
    {
      current_page: records.current_page,
      total_pages: records.total_pages,
      total_count: records.total_count,
      per_page: records.limit_value
    }
  end
end
