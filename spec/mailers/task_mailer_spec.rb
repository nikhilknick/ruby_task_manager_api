require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  let(:task) { create(:task) }

  describe "#task_created" do
    let(:mail) { described_class.task_created(task) }

    it "renders the headers" do
      expect(mail.subject).to eq("New Task Created")
      expect(mail.to).to eq([task.user.email])
      expect(mail.from).to eq(["from@example.com"])
    end
  end

  describe "#task_completed" do
    let(:mail) { described_class.task_completed(task) }

    it "renders the headers" do
      expect(mail.subject).to eq("Task Completed 🎉")
      expect(mail.to).to eq([task.user.email])
    end
  end
end
