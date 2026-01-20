require "swagger_helper"

RSpec.describe "Tasks API", openapi_spec: "v1/swagger.yaml" do
  let(:Authorization) { "Bearer valid.jwt.token" }

  # =========================
  # GET /tasks
  # =========================
  path "/tasks" do
    get "List tasks" do
      tags "Tasks"
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
        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        run_test!
      end
    end

    # =========================
    # POST /tasks
    # =========================
    post "Create task" do
      tags "Tasks"
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
        run_test!
      end

      response "422", "invalid request" do
        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  # =========================
  # /tasks/{id}
  # =========================
  path "/tasks/{id}" do
    parameter name: :id, in: :path, type: :integer

    # =========================
    # GET /tasks/{id}
    # =========================
    get "Show task" do
      tags "Tasks"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "task found" do
        run_test!
      end

      response "404", "not found" do
        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        run_test!
      end
    end

    # =========================
    # PUT /tasks/{id}
    # =========================
    put "Update task" do
      tags "Tasks"
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
        run_test!
      end

      response "422", "invalid update" do
        run_test!
      end

      response "404", "not found" do
        run_test!
      end
    end

    # =========================
    # DELETE /tasks/{id}
    # =========================
    delete "Delete task" do
      tags "Tasks"
      security [ bearerAuth: [] ]

      response "204", "task deleted" do
        run_test!
      end

      response "404", "not found" do
        run_test!
      end

      response "401", "unauthorized" do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
