require "swagger_helper"

RSpec.describe "API V1 Users", openapi_spec: "v1/swagger.yaml" do
  let(:Authorization) { "Bearer valid.jwt.token" }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  # =========================
  # GET /api/v1/users/{id}
  # =========================
  path "/api/v1/users/{id}" do
    parameter name: :id, in: :path, type: :integer

    get "Show user" do
      tags "API V1 Users"
      produces "application/json"
      security [ bearerAuth: [] ]

      response "200", "user found" do
        let(:id) { user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string },
                 email: { type: :string },
                 created_at: { type: :string, format: :date_time }
               }

        run_test!
      end

      response "403", "forbidden" do
        let(:id) { other_user.id }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "404", "not found" do
        let(:id) { 99999 }
        let(:Authorization) { auth_headers(user)["Authorization"] }
        run_test!
      end

      response "401", "unauthorized" do
        let(:id) { user.id }
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
