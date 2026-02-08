require "swagger_helper"

RSpec.describe "API V1 Nested User Tasks", openapi_spec: "v1/swagger.yaml" do
  let(:Authorization) { "Bearer valid.jwt.token" }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:task_instance) { create(:task, user: user) }

  # =========================
  # GET /api/v1/users/{user_id}/tasks
  # =========================
  path "/api/v1/users/{user_id}/tasks" do
    parameter name: :user_id, in: :path, type: :integer

    get "List user tasks" do
      tags "API V1 Nested Tasks"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per, in: :query, type: :integer, required: false
      parameter name: :status, in: :query, type: :string, enum: %w[todo in_progress completed]
      parameter name: :priority, in: :query, type: :string, enum: %w[low medium high]
      parameter name: :q, in: :query, type: :string, description: "Search by title"

      response "200", "tasks listed" do
        let(:user_id) { user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        # Define optional query parameters as nil (they're optional)
        let(:page) { nil }
        let(:per) { nil }
        let(:status) { nil }
        let(:priority) { nil }
        let(:q) { nil }
        before { create_list(:task, 3, user: user) }
        run_test!
      end

      response "403", "forbidden" do
        let(:user_id) { other_user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:page) { nil }
        let(:per) { nil }
        let(:status) { nil }
        let(:priority) { nil }
        let(:q) { nil }
        run_test!
      end

      response "401", "unauthorized" do
        let(:user_id) { user.id }
        let(:Authorization) { nil }
        let(:page) { nil }
        let(:per) { nil }
        let(:status) { nil }
        let(:priority) { nil }
        let(:q) { nil }
        run_test!
      end
    end

    # =========================
    # POST /api/v1/users/{user_id}/tasks
    # =========================
    post "Create user task" do
      tags "API V1 Nested Tasks"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          status: { type: :string, enum: %w[todo in_progress completed] },
          priority: { type: :string, enum: %w[low medium high] },
          due_date: { type: :string, format: :date }
        },
        required: %w[title status priority]
      }

      response "201", "task created" do
        let(:user_id) { user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: attributes_for(:task) } }
        run_test!
      end

      response "403", "forbidden" do
        let(:user_id) { other_user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: attributes_for(:task) } }
        run_test!
      end

      response "422", "invalid request" do
        let(:user_id) { user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "", status: "", priority: "" } } }
        run_test!
      end
    end
  end

  # =========================
  # GET /api/v1/users/{user_id}/tasks/statistics
  # =========================
  path "/api/v1/users/{user_id}/tasks/statistics" do
    parameter name: :user_id, in: :path, type: :integer

    get "Get user task statistics" do
      tags "API V1 Nested Tasks"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "statistics retrieved" do
        let(:user_id) { user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        before { create_list(:task, 3, user: user) }
        run_test!
      end

      response "403", "forbidden" do
        let(:user_id) { other_user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "401", "unauthorized" do
        let(:user_id) { user.id }
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  # =========================
  # /api/v1/users/{user_id}/tasks/{id}
  # =========================
  path "/api/v1/users/{user_id}/tasks/{id}" do
    parameter name: :user_id, in: :path, type: :integer
    parameter name: :id, in: :path, type: :integer

    get "Show user task" do
      tags "API V1 Nested Tasks"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "task found" do
        let(:user_id) { user.id }
        let(:id) { task_instance.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "403", "forbidden" do
        let(:user_id) { other_user.id }
        let(:id) { create(:task, user: other_user).id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "404", "not found" do
        let(:user_id) { user.id }
        let(:id) { 99999 }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end
    end

    put "Update user task" do
      tags "API V1 Nested Tasks"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          status: { type: :string, enum: %w[todo in_progress completed] },
          priority: { type: :string, enum: %w[low medium high] },
          due_date: { type: :string, format: :date }
        }
      }

      response "200", "task updated" do
        let(:user_id) { user.id }
        let(:id) { task_instance.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "Updated Task" } } }
        run_test!
      end

      response "403", "forbidden" do
        let(:user_id) { other_user.id }
        let(:id) { create(:task, user: other_user).id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "Updated Task" } } }
        run_test!
      end

      response "404", "not found" do
        let(:user_id) { user.id }
        let(:id) { 99999 }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "Updated Task" } } }
        run_test!
      end
    end

    delete "Delete user task" do
      tags "API V1 Nested Tasks"
      security [ bearerAuth: [] ]

      response "204", "task deleted" do
        let(:user_id) { user.id }
        let(:id) { task_instance.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "403", "forbidden" do
        let(:user_id) { other_user.id }
        let(:id) { create(:task, user: other_user).id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "404", "not found" do
        let(:user_id) { user.id }
        let(:id) { 99999 }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end
    end
  end
end
