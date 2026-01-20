require "swagger_helper"

RSpec.describe "Authentication API", openapi_spec: "v1/swagger.yaml" do
    path "/signup" do
      post "User signup" do
        tags "Auth"
        consumes "application/json"
        produces "application/json"
  
        parameter name: :payload, in: :body, schema: {
          type: :object,
          properties: {
            user: {
              type: :object,
              properties: {
                name: { type: :string },
                email: { type: :string },
                password: { type: :string },
                password_confirmation: { type: :string }
              },
              required: %w[name email password password_confirmation]
            }
          },
          required: ["user"]
        }
  
        # 👇 THIS IS THE IMPORTANT PART
        request_body_example name: "Signup payload", value: {
          user: {
            name: "Nick",
            email: "nick@test.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
  
        response "201", "user created" do
          run_test!
        end
  
        response "422", "invalid request" do
          run_test!
        end
      end
    end

  path "/login" do
    post "User login" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :auth, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: "nick@test.com" },
          password: { type: :string, example: "password123" }
        },
        required: %w[email password]
      }

      response "200", "login successful" do
        schema type: :object,
               properties: {
                 token: { type: :string, example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." }
               }

        run_test!
      end

      response "401", "invalid credentials" do
        run_test!
      end
    end
  end
end
