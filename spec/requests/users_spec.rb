require 'rails_helper'

RSpec.describe "Users API", type: :request do
  describe "POST /signup" do
    it "creates a user and returns a JWT token" do
      post "/signup", params: {
        user: {
          email: "test@example.com",
          name: "Test User",
          password: "password123",
          password_confirmation: "password123"
        }
      }

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)
      expect(body).to have_key("token")
    end

    it "returns error for invalid data" do
      post "/signup", params: {
        user: {
          email: "",
          password: "password123"
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
