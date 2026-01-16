require 'rails_helper'

RSpec.describe "Tasks API", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /tasks" do
    before { create_list(:task, 3, user: user) }

    it "returns only current user's tasks" do
      get "/tasks", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(3)
    end

    it "returns unauthorized without token" do
      get "/tasks"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /tasks/:id" do
    it "returns the task for the current user" do
      task = create(:task, user: user)

      get "/tasks/#{task.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(task.id)
    end
  end

  describe "POST /tasks" do
    it "creates a task for the authenticated user" do
      expect {
        post "/tasks",
             params: {
               task: {
                 title: "New Task",
                 status: "pending"
               }
             },
             headers: headers
      }.to change(Task, :count).by(1)

      body = JSON.parse(response.body)
      expect(response).to have_http_status(:created)
      expect(body["title"]).to eq("New Task")
    end

    it "returns 422 for invalid task" do
      post "/tasks",
           params: {
             task: {
               title: "",
               status: ""
             }
           },
           headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PUT /tasks/:id" do
    it "updates the user's task" do
      task = create(:task, user: user)

      put "/tasks/#{task.id}",
          params: { task: { title: "Updated Task" } },
          headers: headers

      expect(response).to have_http_status(:ok)
      expect(task.reload.title).to eq("Updated Task")
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes the user's task" do
      task = create(:task, user: user)

      expect {
        delete "/tasks/#{task.id}", headers: headers
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  describe "Authorization" do
    it "does not allow access to another user's task" do
      other_user = create(:user)
      task = create(:task, user: other_user)

      get "/tasks/#{task.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end
end
