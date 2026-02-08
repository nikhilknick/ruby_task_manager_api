require "rails_helper"

RSpec.describe "API V1 Tasks", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/tasks" do
    before do
      create_list(:task, 3, user: user)
      create_list(:task, 2, user: other_user)
    end

    it "returns only current user's tasks" do
      get api_v1_tasks_path, headers: headers

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["data"].length).to eq(3)
      expect(json["meta"]["total_count"]).to eq(3)
    end

    it "returns unauthorized without token" do
      get api_v1_tasks_path

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/tasks/:id" do
    it "returns the task for the current user" do
      task = create(:task, user: user)

      get api_v1_task_path(task), headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["id"]).to eq(task.id)
    end
  end

  describe "POST /api/v1/tasks" do
    it "creates a task for the authenticated user" do
      expect {
        post api_v1_tasks_path,
             params: {
               task: {
                 title: "New Task",
                 status: "completed",
                 priority: "low"
               }
             },
             headers: headers
      }.to change(Task, :count).by(1)

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:created)
      expect(body["title"]).to eq("New Task")
      expect(body["status"]).to eq("completed")
      expect(body["priority"]).to eq("low")
    end
  end

  describe "GET /api/v1/tasks/statistics" do
    before do
      create(:task, user: user, status: "todo", priority: "low")
      create(:task, user: user, status: "in_progress", priority: "medium")
      create(:task, user: user, status: "completed", priority: "high")
      # Create task and then update due_date to bypass validation for testing overdue
      overdue_task = create(:task, user: user, status: "completed", priority: "high")
      overdue_task.update_column(:due_date, Date.yesterday)
      create(:task, user: user, status: "todo", priority: "low", due_date: Date.today)
    end

    it "returns task statistics" do
      get statistics_api_v1_tasks_path, headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["total"]).to eq(5)
      expect(body["by_status"]["todo"]).to eq(2)
      expect(body["by_status"]["in_progress"]).to eq(1)
      expect(body["by_status"]["completed"]).to eq(2)
      expect(body["by_priority"]["low"]).to eq(2)
      expect(body["by_priority"]["medium"]).to eq(1)
      expect(body["by_priority"]["high"]).to eq(2)
      expect(body["overdue"]).to eq(1)
      expect(body["due_today"]).to eq(1)
    end

    it "returns unauthorized without token" do
      get statistics_api_v1_tasks_path

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
