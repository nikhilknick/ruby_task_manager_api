require "rails_helper"

RSpec.describe "API V1 Nested User Tasks", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/users/:user_id/tasks" do
    before do
      create_list(:task, 3, user: user)
      create_list(:task, 2, user: other_user)
    end

    it "returns tasks for the specified user" do
      get api_v1_user_tasks_path(user), headers: headers

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["data"].length).to eq(3)
      expect(json["meta"]["total_count"]).to eq(3)
    end

    it "returns forbidden when accessing another user's tasks" do
      get api_v1_user_tasks_path(other_user), headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns unauthorized without token" do
      get api_v1_user_tasks_path(user)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "POST /api/v1/users/:user_id/tasks" do
    it "creates a task for the specified user" do
      expect {
        post api_v1_user_tasks_path(user),
             params: {
               task: {
                 title: "Nested Task",
                 status: "todo",
                 priority: "high"
               }
             },
             headers: headers
      }.to change(Task, :count).by(1)

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:created)
      expect(body["title"]).to eq("Nested Task")
      # Task belongs to user, but serializer doesn't include user_id
      expect(Task.find(body["id"]).user_id).to eq(user.id)
    end

    it "returns forbidden when creating task for another user" do
      expect {
        post api_v1_user_tasks_path(other_user),
             params: {
               task: {
                 title: "Unauthorized Task",
                 status: "todo",
                 priority: "high"
               }
             },
             headers: headers
      }.not_to change(Task, :count)

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/users/:user_id/tasks/:id" do
    it "returns the task for the specified user" do
      task = create(:task, user: user)

      get api_v1_user_task_path(user, task), headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["id"]).to eq(task.id)
    end

    it "returns forbidden when accessing another user's task" do
      task = create(:task, user: other_user)

      get api_v1_user_task_path(other_user, task), headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/users/:user_id/tasks/statistics" do
    before do
      create(:task, user: user, status: "todo", priority: "low")
      create(:task, user: user, status: "completed", priority: "high")
    end

    it "returns statistics for the specified user's tasks" do
      get statistics_api_v1_user_tasks_path(user), headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["total"]).to eq(2)
      expect(body["by_status"]["todo"]).to eq(1)
      expect(body["by_status"]["completed"]).to eq(1)
    end

    it "returns forbidden when accessing another user's statistics" do
      get statistics_api_v1_user_tasks_path(other_user), headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end
end
