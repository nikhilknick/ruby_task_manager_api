class TaskNotificationJob < ApplicationJob
  queue_as :default

  def perform(task_id, event)
    task = Task.find(task_id)

    case event
    when :created
      TaskMailer.task_created(task).deliver_now
    when :completed
      TaskMailer.task_completed(task).deliver_now
    end
  end
end
