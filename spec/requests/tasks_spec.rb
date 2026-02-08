require "rails_helper"

RSpec.describe "Tasks API", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /tasks" do
    before do
      create_list(:task, 3, user: user)
      create_list(:task, 2, user: other_user)
    end

    it "returns only current user's tasks" do
      get tasks_path, headers: headers

      json = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json["data"].length).to eq(3)
      expect(json["meta"]["total_count"]).to eq(3)
    end

    it "returns unauthorized without token" do
      get tasks_path

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /tasks/:id" do
    it "returns the task for the current user" do
      task = create(:task, user: user)

      get task_path(task), headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["id"]).to eq(task.id)
    end
  end

  describe "POST /tasks" do
    it "creates a task for the authenticated user" do
      expect {
        post tasks_path,
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

    it "enqueues email job on task creation" do
      expect {
        post tasks_path,
             params: { task: attributes_for(:task) },
             headers: headers
      }.to have_enqueued_job(TaskNotificationJob)
    end

    it "returns 422 for invalid task" do
      post tasks_path,
           params: {
             task: {
               title: "",
               status: "",
               priority: ""
             }
           },
           headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PUT /tasks/:id" do
    it "updates the user's task" do
      task = create(:task, user: user)

      put task_path(task),
          params: {
            task: { title: "Updated Task" }
          },
          headers: headers

      expect(response).to have_http_status(:ok)
      expect(task.reload.title).to eq("Updated Task")
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes the user's task" do
      task = create(:task, user: user)

      expect {
        delete task_path(task), headers: headers
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "Authorization" do
    it "does not allow access to another user's task" do
      task = create(:task, user: other_user)

      get task_path(task), headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "Pagination" do
    before do
      create_list(:task, 15, user: user)
    end

    it "returns paginated results with metadata" do
      get tasks_path, params: { page: 1, per: 5 }, headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["data"].size).to eq(5)
      expect(body["meta"]["current_page"]).to eq(1)
      expect(body["meta"]["total_pages"]).to eq(3)
      expect(body["meta"]["total_count"]).to eq(15)
    end
  end

  # filtering by status spec
  describe "Filtering by status" do
    before do
      create(:task, user: user, status: "completed", title: "Done task")
      create(:task, user: user, status: "todo", title: "Todo task")
    end
  
    it "returns only tasks with given status" do
      get tasks_path, params: { status: "completed" }, headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["data"].length).to eq(1)
      expect(body["data"].first["status"]).to eq("completed")
    end
  end

  # filtering by priority spec
  describe "Filtering by priority" do
    before do
      create(:task, user: user, priority: "high", title: "High priority")
      create(:task, user: user, priority: "low", title: "Low priority")
    end
  
    it "returns only tasks with given priority" do
      get tasks_path, params: { priority: "high" }, headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["data"].length).to eq(1)
      expect(body["data"].first["priority"]).to eq("high")
    end
  end

  # search by title spec
  describe "Search by title" do
    before do
      create(:task, user: user, title: "Deploy backend")
      create(:task, user: user, title: "Fix UI bugs")
    end
  
    it "returns tasks matching search query" do
      get tasks_path, params: { q: "deploy" }, headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["data"].length).to eq(1)
      expect(body["data"].first["title"]).to include("Deploy")
    end
  end

  # sorting tasks spec
  describe "Sorting tasks" do
    before do
      create(:task, user: user, priority: "low", title: "Low priority")
      create(:task, user: user, priority: "high", title: "High priority")
    end
  
    it "sorts tasks by priority ascending" do
      get tasks_path,
          params: { sort_by: "priority", order: "asc" },
          headers: headers

      body = JSON.parse(response.body)
      priorities = body["data"].map { |t| t["priority"] }

      expect(response).to have_http_status(:ok)
      expect(priorities).to eq(%w[low high])
    end
  end

  # TaskSerializer spec
  describe "TaskSerializer" do
    it "returns consistent task attributes" do
      task = create(:task, user: user)
  
      get task_path(task), headers: headers

      body = JSON.parse(response.body)

      expect(body.keys).to contain_exactly(
        "id",
        "title",
        "description",
        "status",
        "priority",
        "due_date",
        "created_at",
        "updated_at"
      )
    end
  end

  # Statistics endpoint spec
  describe "GET /tasks/statistics" do
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
      get statistics_tasks_path, headers: headers

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
      get statistics_tasks_path

      expect(response).to have_http_status(:unauthorized)
    end
  end
  
  
  
  
  
end
