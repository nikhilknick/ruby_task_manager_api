require "rails_helper"

RSpec.describe "API V1 Users", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/users/:id" do
    it "returns the current user's profile" do
      get api_v1_user_path(user), headers: headers

      body = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(body["id"]).to eq(user.id)
      expect(body["name"]).to eq(user.name)
      expect(body["email"]).to eq(user.email)
    end

    it "returns forbidden when accessing another user's profile" do
      get api_v1_user_path(other_user), headers: headers

      expect(response).to have_http_status(:forbidden)
    end

    it "returns unauthorized without token" do
      get api_v1_user_path(user)

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
