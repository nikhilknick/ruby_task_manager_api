module Api
  module V1
    class TasksController < BaseController
      before_action :authenticate_request
      before_action :set_user_if_nested, only: [:index, :create, :statistics, :show, :update, :destroy]
      before_action :set_task, only: [:show, :update, :destroy]

      SORTABLE_FIELDS = %w[created_at due_date priority].freeze

      def index
        tasks = tasks_scope
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
        task = tasks_scope.build(task_params)

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

      def statistics
        tasks = tasks_scope
        
        stats = {
          total: tasks.count,
          by_status: {
            todo: tasks.todo.count,
            in_progress: tasks.in_progress.count,
            completed: tasks.completed.count
          },
          by_priority: {
            low: tasks.low.count,
            medium: tasks.medium.count,
            high: tasks.high.count
          },
          overdue: tasks.where("due_date < ?", Date.today).count,
          due_today: tasks.where(due_date: Date.today).count,
          due_this_week: tasks.where(due_date: Date.today..Date.today + 7.days).count
        }

        render json: stats, status: :ok
      end

      private

      def set_task
        @task = tasks_scope.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Not Found" }, status: :not_found
      end

      def set_user_if_nested
        if params[:user_id].present?
          @user = User.find(params[:user_id])
          # Ensure user can only access their own tasks
          unless @user == current_user
            render json: { error: "Forbidden" }, status: :forbidden
            return false
          end
        end
        true
      end

      def tasks_scope
        @user ? @user.tasks : current_user.tasks
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
  end
end
