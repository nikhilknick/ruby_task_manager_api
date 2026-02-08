require "swagger_helper"

RSpec.describe "API V1 Tasks", openapi_spec: "v1/swagger.yaml" do
  let(:Authorization) { "Bearer valid.jwt.token" }
  let(:user) { create(:user) }
  let(:task_instance) { create(:task, user: user) }

  # =========================
  # GET /api/v1/tasks
  # =========================
  path "/api/v1/tasks" do
    get "List tasks" do
      tags "API V1 Tasks"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per, in: :query, type: :integer, required: false
      parameter name: :status, in: :query, type: :string, enum: %w[todo in_progress completed]
      parameter name: :priority, in: :query, type: :string, enum: %w[low medium high]
      parameter name: :q, in: :query, type: :string, description: "Search by title"
      parameter name: :sort_by, in: :query, type: :string, enum: %w[created_at due_date priority]
      parameter name: :order, in: :query, type: :string, enum: %w[asc desc]

      response "200", "tasks listed" do
        let(:Authorization) { auth_headers(user)["Authorization"] }
        # Define optional query parameters as nil (they're optional)
        let(:page) { nil }
        let(:per) { nil }
        let(:status) { nil }
        let(:priority) { nil }
        let(:q) { nil }
        let(:sort_by) { nil }
        let(:order) { nil }
        before { create_list(:task, 3, user: user) }
        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        let(:page) { nil }
        let(:per) { nil }
        let(:status) { nil }
        let(:priority) { nil }
        let(:q) { nil }
        let(:sort_by) { nil }
        let(:order) { nil }
        run_test!
      end
    end

    # =========================
    # POST /api/v1/tasks
    # =========================
    post "Create task" do
      tags "API V1 Tasks"
      consumes "application/json"
      produces "application/json"
      security [ bearerAuth: [] ]

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: "Deploy backend" },
          description: { type: :string, example: "Deploy Rails API to prod" },
          status: {
            type: :string,
            enum: %w[todo in_progress completed],
            example: "todo"
          },
          priority: {
            type: :string,
            enum: %w[low medium high],
            example: "high"
          },
          due_date: {
            type: :string,
            format: :date,
            example: "2026-02-01"
          }
        },
        required: %w[title status priority]
      }

      response "201", "task created" do
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: attributes_for(:task) } }
        run_test!
      end

      response "422", "invalid request" do
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "", status: "", priority: "" } } }
        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        let(:task) { { task: attributes_for(:task) } }
        run_test!
      end
    end
  end

  # =========================
  # GET /api/v1/tasks/statistics
  # =========================
  path "/api/v1/tasks/statistics" do
    get "Get task statistics" do
      tags "API V1 Tasks"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "statistics retrieved" do
        let(:Authorization) { auth_headers(user)["Authorization"] }
        before { create_list(:task, 3, user: user) }
        schema type: :object,
               properties: {
                 total: { type: :integer },
                 by_status: {
                   type: :object,
                   properties: {
                     todo: { type: :integer },
                     in_progress: { type: :integer },
                     completed: { type: :integer }
                   }
                 },
                 by_priority: {
                   type: :object,
                   properties: {
                     low: { type: :integer },
                     medium: { type: :integer },
                     high: { type: :integer }
                   }
                 },
                 overdue: { type: :integer },
                 due_today: { type: :integer },
                 due_this_week: { type: :integer }
               }

        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  # =========================
  # /api/v1/tasks/{id}
  # =========================
  path "/api/v1/tasks/{id}" do
    parameter name: :id, in: :path, type: :integer

    # =========================
    # GET /api/v1/tasks/{id}
    # =========================
    get "Show task" do
      tags "API V1 Tasks"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "task found" do
        let(:id) { task_instance.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "404", "not found" do
        let(:id) { 99999 }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "401", "unauthorized" do
        let(:id) { task_instance.id }
        let(:Authorization) { nil }
        run_test!
      end
    end

    # =========================
    # PUT /api/v1/tasks/{id}
    # =========================
    put "Update task" do
      tags "API V1 Tasks"
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
        let(:id) { task_instance.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "Updated Task" } } }
        run_test!
      end

      response "422", "invalid update" do
        let(:id) { task_instance.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "" } } }
        run_test!
      end

      response "404", "not found" do
        let(:id) { 99999 }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        let(:task) { { task: { title: "Updated Task" } } }
        run_test!
      end
    end

    # =========================
    # DELETE /api/v1/tasks/{id}
    # =========================
    delete "Delete task" do
      tags "API V1 Tasks"
      security [ bearerAuth: [] ]

      response "204", "task deleted" do
        let(:id) { task_instance.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "404", "not found" do
        let(:id) { 99999 }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "401", "unauthorized" do
        let(:id) { task_instance.id }
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
