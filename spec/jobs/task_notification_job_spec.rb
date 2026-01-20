require 'rails_helper'

RSpec.describe TaskNotificationJob, type: :job do
  let(:task) { create(:task) }

  it "enqueues job" do
    expect {
      TaskNotificationJob.perform_later(task.id, :created)
    }.to have_enqueued_job.with(task.id, :created)
  end
end